from pydub import AudioSegment
import sys
from tqdm import tqdm
import threading
import time

total_audio_length = 0

def get_audio_length(file_path):
    audio = AudioSegment.from_file(file_path)
    duration = len(audio) # Get's length of audio in ms
    return duration

def get_length_of_all_audio(audio_files):
    total_length = 0

    for i, file in enumerate(audio_files):
        if i != 0:
            total_length += get_audio_length(file)

    return total_length

def increment(audio_file):
    file_length = get_audio_length(audio_file)
    percent_to_increment = (file_length / total_audio_length) * 100
    progress_bar.update(percent_to_increment)

def _setup_loading_bar():
    return get_length_of_all_audio(sys.argv)

def _update_time(bar):
    while True:
        time.sleep(15)
        bar.update(0)  # refresh elapsed time without advancing progress bar

total_audio_length = _setup_loading_bar()
progress_bar = tqdm(total=100, bar_format='{desc} {percentage:3.0f}% |{bar}| {elapsed} elapsed', desc='Processing', ncols=80)
threading.Thread(target=_update_time, args=(progress_bar,), daemon=True).start()