import requests
import transcriber
import gentle
import json
import mute_profanity
import sys
import loading
from tqdm import tqdm

def change_audio_file_name(audio_file):
    start_index = -4
    result = audio_file[:start_index]
    new_name = result + "_edited.mp3"
    return new_name

if __name__ == "__main__":

    gentle.start()

    for i, arg in enumerate(sys.argv):
        if i < 1:
            continue
        audio_file = arg
        transcription = transcriber.transcribe(audio_file)
        transcriber.save_transcription_as_text_file(transcription)

        with open(audio_file, 'rb') as audio:
            response = requests.post(
                "http://localhost:8765/transcriptions?async=false",
                files = { "audio": audio },
                data = { "transcript": transcription }
            )

            if response.status_code == 200:
                alignment = response.json()
                with open("alignment.json", "w") as file:  # Open file for writing
                    json.dump(alignment, file, indent=2)  # Serialize and write JSON
                tqdm.write("Alignment Successful.")
            else:
                tqdm.write("Error:", response.text)

            tqdm.write("Creating edited audio file...")
            new_file_name = change_audio_file_name(audio_file)
            mute_profanity.mute_profanity("alignment.json", audio_file, "profanity.txt", new_file_name)


    gentle.stop_docker(gentle.container_name)
    loading.progress_bar.close()

