import os
import subprocess

if __name__ == "__main__":
    # go through all the files in the directory and subdirectories
    # find wav files and convert them to mp3 using ffmpeg
    # delete the wav files
    
    # get the current directory
    current_directory = os.getcwd()
    # get all the files in the current directory and subdirectories
    all_files = []
    for root, dirs, files in os.walk(current_directory):
        for file in files:
            all_files.append(os.path.join(root, file))
    # get all the wav files
    wav_files = [file for file in all_files if file.endswith('.wav')]
    # convert all the wav files to mp3
    for wav_file in wav_files:
        mp3_file = wav_file.replace('.wav', '.mp3')
        # convert the wav file to mp3 320kbps fixed bitrate
        subprocess.run(['ffmpeg', '-i', wav_file, '-b:a', '320k', mp3_file])
        # delete the wav file
        os.remove(wav_file)