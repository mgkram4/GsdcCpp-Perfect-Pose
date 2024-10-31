from flask import Flask, jsonify, request
from flask_cors import CORS
from models.analyzer import PoseAnalyzer
from models.bodyweight import load_bodyweight_poses
from models.functional import load_functional_poses
from models.lifting import load_lifting_poses
from models.yoga import load_yoga_poses

app = Flask(__name__)
CORS(app)

pose_analyzer = PoseAnalyzer()

# Load pose databases
load_yoga_poses(pose_analyzer)
load_bodyweight_poses(pose_analyzer)
load_functional_poses(pose_analyzer)
load_lifting_poses(pose_analyzer)

@app.route('/')
def index():
    return jsonify({"message": "Welcome to the Perfect Pose API"})

def analyze_pose(category):
    if 'file' not in request.files:
        return jsonify({"error": "No file part"}), 400
    
    file = request.files['file']
    pose_name = request.form.get('pose_name')
    
    if file.filename == '':
        return jsonify({"error": "No selected file"}), 400
    
    if file and pose_name:
        filename = f"temp_{file.filename}"
        file.save(filename)
        
        try:
            result = pose_analyzer.analyze_user_pose(filename, category, pose_name)
            return jsonify(result), 200
        except ValueError as e:
            return jsonify({"error": str(e)}), 400
        finally:
            import os
            os.remove(filename)
    
    return jsonify({"error": "Invalid request"}), 400

@app.route('/analyze_pose', methods=['POST'])
def analyze_pose_endpoint():
    category = request.form.get('category')
    pose_name = request.form.get('pose_name')
    if not category or not pose_name:
        return jsonify({"error": "Category and pose_name are required"}), 400
    return analyze_pose(category, pose_name)

@app.route('/analyze_pose_yoga', methods=['POST'])
def analyze_yoga():
    return analyze_pose('yoga')

@app.route('/analyze_pose_bodyweight', methods=['POST'])
def analyze_bodyweight():
    return analyze_pose('bodyweight')

@app.route('/analyze_pose_functional', methods=['POST'])
def analyze_functional():
    return analyze_pose('functional')

@app.route('/analyze_pose_lifting', methods=['POST'])
def analyze_lifting():
    return analyze_pose('lifting')

if __name__ == '__main__':
    app.run(debug=True)