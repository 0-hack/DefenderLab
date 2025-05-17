from flask import Flask, jsonify, send_file
import subprocess
import os

app = Flask(__name__)

@app.route('/')
def index():
    return send_file('index.html')

@app.route('/reset', methods=['POST'])
def reset_webtop():
    try:
        script_path = '/opt/DefenderLab/reset_webtop.sh'
        result = subprocess.run(
            ['sudo', script_path],
            capture_output=True,
            text=True,
            check=True
        )
        return jsonify({
            'success': True,
            'output': result.stdout
        })
    except subprocess.CalledProcessError as e:
        return jsonify({
            'success': False,
            'error': e.stderr
        }), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)