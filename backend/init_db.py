import psycopg2
import os
import sys

def init_database():
    """Initialize database schema"""
    try:
        # Database connection parameters
        db_params = {
            'host': os.getenv('DB_HOST'),
            'database': os.getenv('DB_NAME'),
            'user': os.getenv('DB_USER'),
            'password': os.getenv('DB_PASSWORD'),
            'port': os.getenv('DB_PORT', '5432')
        }
        
        # Connect to database
        conn = psycopg2.connect(**db_params)
        cur = conn.cursor()
        
        # Create tasks table
        cur.execute('''
            CREATE TABLE IF NOT EXISTS tasks (
                id SERIAL PRIMARY KEY,
                title VARCHAR(255) NOT NULL,
                description TEXT,
                completed BOOLEAN DEFAULT FALSE,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        
        # Insert sample data
        cur.execute('''
            INSERT INTO tasks (title, description, completed) 
            VALUES 
            ('Learn Terraform', 'Build infrastructure as code skills', true),
            ('Master AWS', 'Complete cloud certification', false),
            ('Build Portfolio', 'Create impressive cloud projects', false)
            ON CONFLICT DO NOTHING
        ''')
        
        conn.commit()
        print("Database initialized successfully!")
        
    except Exception as e:
        print(f"Error initializing database: {e}")
        sys.exit(1)
    finally:
        if 'conn' in locals():
            conn.close()

if __name__ == '__main__':
    init_database()
