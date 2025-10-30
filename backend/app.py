from flask import Flask, jsonify, request
from flask_cors import CORS
import psycopg2
import os
from datetime import datetime

app = Flask(__name__)
CORS(app)

# Database configuration from environment variables
DB_HOST = os.getenv('DB_HOST')
DB_NAME = os.getenv('DB_NAME')
DB_USER = os.getenv('DB_USER')
DB_PASSWORD = os.getenv('DB_PASSWORD')
DB_PORT = os.getenv('DB_PORT', '5432')

def get_db_connection():
    """Create database connection"""
    try:
        conn = psycopg2.connect(
            host=DB_HOST,
            database=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD,
            port=DB_PORT
        )
        return conn
    except Exception as e:
        print(f"Database connection error: {e}")
        return None

@app.route('/')
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'service': 'backend-api',
        'timestamp': datetime.utcnow().isoformat()
    })

@app.route('/api/tasks', methods=['GET'])
def get_tasks():
    """Get all tasks"""
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        cur = conn.cursor()
        cur.execute('SELECT id, title, description, completed, created_at FROM tasks ORDER BY created_at DESC;')
        tasks = cur.fetchall()
        
        task_list = []
        for task in tasks:
            task_list.append({
                'id': task[0],
                'title': task[1],
                'description': task[2],
                'completed': task[3],
                'created_at': task[4].isoformat()
            })
        
        return jsonify(task_list)
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        if conn:
            conn.close()

@app.route('/api/tasks', methods=['POST'])
def create_task():
    """Create a new task"""
    data = request.get_json()
    
    if not data or not data.get('title'):
        return jsonify({'error': 'Title is required'}), 400
    
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        cur = conn.cursor()
        cur.execute(
            'INSERT INTO tasks (title, description, completed) VALUES (%s, %s, %s) RETURNING id;',
            (data['title'], data.get('description', ''), data.get('completed', False))
        )
        task_id = cur.fetchone()[0]
        conn.commit()
        
        return jsonify({'id': task_id, 'message': 'Task created successfully'}), 201
    except Exception as e:
        conn.rollback()
        return jsonify({'error': str(e)}), 500
    finally:
        if conn:
            conn.close()

@app.route('/api/health/detailed')
def detailed_health():
    """Detailed health check with dependency status"""
    db_status = 'healthy'
    try:
        conn = get_db_connection()
        if conn:
            conn.close()
        else:
            db_status = 'unhealthy'
    except:
        db_status = 'unhealthy'
    
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.utcnow().isoformat(),
        'dependencies': {
            'database': db_status
        }
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
