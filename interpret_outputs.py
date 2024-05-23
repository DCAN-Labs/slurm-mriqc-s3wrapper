import os
import json
from collections import defaultdict
from pathlib import Path

def load_json_metrics(file_path):
    with open(file_path, 'r') as file:
        data = json.load(file)
    return data

def evaluate_t1_files(subject_folder, log_file):
    files_metrics = defaultdict(dict)
    
    # Explore each session folder under the subject
    for session_folder in subject_folder.glob('*/ses-*'):
        anat_dir = session_folder / 'anat'
        
        for file in anat_dir.glob('*_T1w.json'):
            metrics = load_json_metrics(file)
            files_metrics[file] = metrics

    return files_metrics

def winner_take_all(files_metrics, log_file):
    best_scores = defaultdict(int)
    metrics_preferences = {
        'cjv': ('min', lambda x: x),  # Lower is better
        'efc': ('min', lambda x: x),  # Lower is better
        'fwhm_avg': ('min', lambda x: x),  # Lower is better
        'snr_total': ('min', lambda x: x),  # Lower is better
        'snrd_total': ('min', lambda x: x),  # Lower is better
        'cnr': ('max', lambda x: x),  # Higher is better
        'fber': ('max', lambda x: x),  # Higher is better
        'qi_1': ('min', abs),  # Closer to zero is better
        'qi_2': ('min', abs)   # Closer to zero is better
    }

    log_file.write("\nMetric evaluation results:\n")
    # Evaluate best file for each metric
    for metric, (preference, func) in metrics_preferences.items():
        if preference == 'min':
            best_file = min(files_metrics, key=lambda x: func(files_metrics[x][metric]))
        elif preference == 'max':
            best_file = max(files_metrics, key=lambda x: func(files_metrics[x][metric]))
        best_scores[best_file] += 1
        log_file.write(f"Best for {metric}: {best_file} with value {files_metrics[best_file][metric]}\n")

    # Determine the overall best file based on most wins
    overall_best_file = max(best_scores, key=best_scores.get)
    log_file.write("\nWinner-take-all summary:\n")
    for file, wins in best_scores.items():
        log_file.write(f"{file}: {wins} wins\n")
    log_file.write(f"Overall Best File: {overall_best_file}\n")

    return overall_best_file

def find_best_t1_json(working_dir):
    working_directory = Path(working_dir)
    overall_best_files = {}

    for subject_dir in working_directory.iterdir():
        if subject_dir.is_dir():
            log_path = working_directory / f"{subject_dir.name}_evaluation_log.txt"
            with open(log_path, 'w') as log_file:
                log_file.write(f"Evaluating subject directory: {subject_dir}\n")
                files_metrics = evaluate_t1_files(subject_dir, log_file)
                if files_metrics:
                    best_file = winner_take_all(files_metrics, log_file)
                    overall_best_files[subject_dir.name] = best_file.name
                else:
                    overall_best_files[subject_dir.name] = "No T1 JSON file found"
                    log_file.write("No T1 JSON file found for this subject.\n")

    return overall_best_files

# Example usage
working_dir = '/home/feczk001/fayzu001/working_dir'  # Path to the working directory where data is consolidated
best_t1_files = find_best_t1_json(working_dir)
for subject, best_file in best_t1_files.items():
    print(f"Subject {subject}: Best T1 JSON file is {best_file}")