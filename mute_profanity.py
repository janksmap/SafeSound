import json
from pydub import AudioSegment
import loading
from tqdm import tqdm

def mute_profanity(json_file, audio_file, custom_words_file, output_file):
    alignment_data = json.load(open(json_file))
    audio = AudioSegment.from_file(audio_file)
    mute_segments = []
    default_fade_duration = 50

    with open(custom_words_file, 'r') as f:
        custom_words = [line.strip().lower().split() for line in f]

    i = 0
    while i < len(alignment_data['words']):
        word_info = alignment_data['words'][i]
        if 'start' in word_info and 'end' in word_info:
            start_ms = int(word_info['start'] * 1000)
            end_ms = int(word_info['end'] * 1000)
            word = word_info['word'].lower()

            matched_phrase = False
            for phrase in custom_words:
                if phrase[0] == word:
                    phrase_index = 1
                    temp_end_ms = start_ms

                    for j in range(i + 1, len(alignment_data['words'])):
                        next_word_info = alignment_data['words'][j]
                        next_word = next_word_info['word'].lower()

                        if 'end' in next_word_info:
                            temp_end_ms = int(next_word_info['end'] * 1000)

                        if phrase_index < len(phrase) and next_word == phrase[phrase_index]:
                            phrase_index += 1

                        if phrase_index == len(phrase):
                            matched_phrase = True
                            break

                    if matched_phrase:
                        mute_segments.append((start_ms, temp_end_ms))
                        i += phrase_index
                        break
            if not matched_phrase:
                i += 1 #increment if not matched
        else:
            i+=1

    muted_audio = audio
    for start_ms, end_ms in reversed(mute_segments):
        silence_duration = end_ms - start_ms
        silence = AudioSegment.silent(silence_duration)
        fade_duration = min(default_fade_duration, len(silence))
        prefix = muted_audio[:start_ms]
        suffix = muted_audio[end_ms:]
        muted_segment = prefix.append(silence, crossfade=fade_duration).append(suffix, crossfade=fade_duration)
        muted_audio = muted_segment

    original_format = audio_file.split('.')[-1]
    muted_audio.export(output_file, format=original_format)
    # muted_audio.export(output_file, format="wav")
    tqdm.write(f"Processing complete. Output saved to {output_file}")
    loading.increment(audio_file)