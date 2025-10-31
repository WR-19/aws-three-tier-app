#!/bin/bash
VPC_ID=$1

echo "🧹 Cleaning up VPC: $VPC_ID"

# Delete NAT Gateways
echo "Deleting NAT Gateways..."
NAT_GWS=$(aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=$VPC_ID" --query 'NatGateways[?State==`available`].NatGatewayId' --output text)
for NAT_GW in $NAT_GWS; do
    echo "Deleting NAT Gateway: $NAT_GW"
    aws ec2 delete-nat-gateway --nat-gateway-id $NAT_GW
    aws ec2 wait nat-gateway-deleted --nat-gateway-ids $NAT_GW
done

# Delete ELBs
echo "Deleting Load Balancers..."
ELBS=$(aws elbv2 describe-load-balancers --query "LoadBalancers[?VpcId=='$VPC_ID'].LoadBalancerArn" --output text)
for ELB in $ELBS; do
    echo "Deleting ELB: $ELB"
    aws elbv2 delete-load-balancer --load-balancer-arn $ELB
done

# Delete EIPs (NAT Gateway EIPs)
echo "Releasing EIPs..."
EIPS=$(aws ec2 describe-addresses --filter "Name=domain,Values=vpc" --query "Addresses[?NetworkInterfaceId==null].AllocationId" --output text)
for EIP in $EIPS; do
    echo "Releasing EIP: $EIP"
    aws ec2 release-address --allocation-id $EIP
done

# Delete Internet Gateway
echo "Deleting Internet Gateway..."
IGW_ID=$(aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$VPC_ID" --query 'InternetGateways[*].InternetGatewayId' --output text)
if [ ! -z "$IGW_ID" ]; then
    echo "Detaching and deleting IGW: $IGW_ID"
    aws ec2 detach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID
    aws ec2 delete-internet-gateway --internet-gateway-id $IGW_ID
fi

# Delete Subnets
echo "Deleting Subnets..."
SUBNETS=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query 'Subnets[*].SubnetId' --output text)
for SUBNET in $SUBNETS; do
    echo "Deleting Subnet: $SUBNET"
    aws ec2 delete-subnet --subnet-id $SUBNET
done

# Delete Route Tables (non-main)
echo "Deleting Route Tables..."
RT_IDS=$(aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$VPC_ID" --query 'RouteTables[?Associations[?Main!=`true`]].RouteTableId' --output text)
for RT_ID in $RT_IDS; do
    echo "Deleting Route Table: $RT_ID"
    aws ec2 delete-route-table --route-table-id $RT_ID
done

# Delete Security Groups
echo "Deleting Security Groups..."
SGS=$(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$VPC_ID" --query 'SecurityGroups[?GroupName!=`default`].GroupId' --output text)
for SG in $SGS; do
    echo "Deleting Security Group: $SG"
    aws ec2 delete-security-group --group-id $SG
done

# Finally delete VPC
echo "Deleting VPC: $VPC_ID"
aws ec2 delete-vpc --vpc-id $VPC_ID

echo "✅ VPC $VPC_ID cleanup complete!"
