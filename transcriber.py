import whisper
import warnings
from tqdm import tqdm
import os
from dotenv import load_dotenv

load_dotenv()

MODEL_VERSION = os.getenv("WHISPER_MODEL") # default is "base"

warnings.filterwarnings("ignore", category=UserWarning, message="FP16 is not supported on CPU")
tqdm.write(f"Loading Whisper {MODEL_VERSION} model...")
model = whisper.load_model(MODEL_VERSION)

def transcribe(audio_file):
    tqdm.write(f"Transcribing using {MODEL_VERSION} model...")
    result = model.transcribe(audio_file)

    return(result['text'])

def save_transcription_as_text_file(transcription):
    filename = "transcription.txt"

    with open(filename, 'w') as file:
        file.write(transcription)

    tqdm.write(f"Transcription has been saved to {filename}")

