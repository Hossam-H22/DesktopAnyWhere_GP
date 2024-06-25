import random
import subprocess
import uuid
import schedule
import pyperclip
import win32api
from PyQt5 import QtCore, QtGui, QtWidgets
import sys
import multiprocessing
from multiprocessing import Event
import time
import psutil
import pygetwindow as gw
import os
import pyautogui
import socketio
import socket
import ctypes
import pyperclip
import requests
from pynput.mouse import Controller, Button
from transformers import AutoModelForSequenceClassification, AutoTokenizer
from transformers import pipeline
from collections import defaultdict
from transformers import BertTokenizerFast
from transformers import AutoModelForTokenClassification
import re
from datetime import datetime, timedelta
from datetime import datetime
import os
import win32com.client
import subprocess
import time
import psutil
from transformers import WhisperForConditionalGeneration, WhisperTokenizer
import torch
from transformers import pipeline
from transformers import WhisperFeatureExtractor
import pygame
from playsound import playsound
from threading import Thread
import tkinter as tk






def convert_seconds(number):
    seconds = int(number)
    fraction = number - seconds
    fraction = round(fraction, 2)
    hours = seconds // 3600
    seconds %= 3600
    minutes = seconds // 60
    seconds %= 60
    seconds += fraction
    format = ""
    if hours != 0:
        format += f"hour: {hours}, "
    if minutes != 0:
        format += f"min: {minutes}, "
    if seconds != 0:
        format += f"sec: {seconds}"

    return format


class Paths:
    def __init__(self):
        self.output_dir = ""

    def get_drive_letters(self):
        """
        Retrieves a list of drive letters for all mounted drives on Windows.
        """
        partitions = []
        for disk in psutil.disk_partitions():
            if disk != 'c:\\':
                drive = disk.device
                partitions.append(drive)
        return partitions

    def execute_command_on_partition(self, command, partition):
        """
        Executes a command on a specific partition.
        """
        try:
            subprocess.run(command, shell=True, cwd=partition, check=True)
            print(f"Command executed successfully on partition {partition}")
        except subprocess.CalledProcessError as e:
            print(f"Error executing command on partition {partition}: {e}")

    def execute_command_on_all_partitions(self, command):
        """
        Executes a command on all partitions.
        """
        drive_letters = self.get_drive_letters()
        # print(drive_letters)
        # self.execute_command_on_partition(command, 'D:\\')
        for drive in drive_letters:
            self.execute_command_on_partition(command, drive)

    def get_all_paths(self):
        start_time = time.time()
        # Define the command to execute
        partitions = self.get_drive_letters()
        for drive in partitions:
            if drive != 'C:\\':
                self.output_dir = drive
                break

        print(f"paths of device will save in note file at: \"{self.output_dir}\" \n")
        self.output_dir = os.path.join(self.output_dir, "directories_files.txt")
        command = f'chcp 65001 && dir /S /B >> {self.output_dir}'

        # Execute the command on all partitions
        self.execute_command_on_all_partitions(command)

        print('\nDone saving paths')
        end_time = time.time()  # Stop measuring time
        period = convert_seconds(end_time - start_time)
        print(f"Time taken to search partitions: ( {period} )")


class kaggleAPI:
    def __init__(self):
        self.project_path = "./"
        nb_id = "andrew2204/gp-models"
        dataset_id = "andrew2204/gp-voices"
        nb_id = "andrew2204/gp-models"
        print("here")
        # self.pull_kaggle_dataset(dataset_id)
        print(self.update_kaggle_dataset())
        print(self.push_kaggle_notebook())
        # print(self.pull_kaggle_notebook(nb_id))
        while "running" in self.get_notebook_status(nb_id):
            print(self.get_notebook_status(nb_id))
        print(self.get_notebook_output(notebook_id=nb_id))

    def execute_terminal_command(self, command):
        result = subprocess.run(command, shell=True, text=True, capture_output=True)
        return result.stdout

    def pull_kaggle_dataset(self, dataset_id):
        command = fr'kaggle datasets metadata -p {self.project_path}\datasets {dataset_id}'
        return self.execute_terminal_command(command)

    def update_kaggle_dataset(self):
        command = fr'kaggle datasets version -p {self.project_path}\datasets -d -m "Updated Dataset"'
        return self.execute_terminal_command(command)

    def pull_kaggle_notebook(self, nb_id):
        command = fr"kaggle kernels pull {nb_id} -p {self.project_path}\notebook -m"
        return self.execute_terminal_command(command)

    def push_kaggle_notebook(self):
        command = fr"kaggle kernels push -p {self.project_path}\notebook"
        return self.execute_terminal_command(command)

    def get_notebook_status(self, notebook_id):
        command = fr"kaggle kernels status {notebook_id}"
        return self.execute_terminal_command(command)

    def get_notebook_output(self, notebook_id):
        command = fr'kaggle kernels output {notebook_id} -p {self.project_path}\nb_output'
        return self.execute_terminal_command(command)


class SupportModelFunctions:
    def __init__(self):
        path = Paths()
        path.get_all_paths()
        self.file_path = path.output_dir
        # self.file_path = "D:\\directories_files.txt"

    def get_file_folder(self, name):
        # file_path = "D:\\directories_files.txt"

        # String to search for
        search_string = name

        # Record the start time
        start_time = time.time()

        # Open the file
        with open(self.file_path, "r", encoding='utf-8') as file:
            # Read the content of the file
            content = file.read()

        # Find the starting indices of all occurrences of the search string
        start_indices = [i for i in range(len(content)) if content.startswith(search_string, i)]

        # Initialize a set to store the extracted paths
        extracted_paths = set()

        # Iterate over the starting indices
        for start_index in start_indices:

            # Find the index of the end of the line preceding the given string
            end_of_previous_line_index = content.rfind("\n", 0, start_index)

            # Extract the line from the end of the previous line to the start index of the given string
            extracted_line = content[end_of_previous_line_index + 1:start_index]

            # Check if the extracted path contains "RECYCLE.BIN", and skip it if it does
            if "RECYCLE.BIN" in extracted_line:
                continue

            # Ensure that the extracted line ends with '\'
            while extracted_line and extracted_line[-1] != '\\':
                extracted_line = extracted_line[:-1]

            if extracted_line in extracted_paths:
                continue

            # Add the extracted line to the set
            os.startfile(extracted_line)
            extracted_paths.add(extracted_line)

            # get first 5 matches only
            if len(extracted_paths) == 5:
                break

        # Record the end time
        end_time = time.time()

        # Calculate the time spent
        time_spent = end_time - start_time
        print("Time spent:", time_spent, "seconds")

        # Do something with the extracted lines
        if extracted_paths:
            print("Extracted content:")
            for i, path in enumerate(extracted_paths, 1):
                print(f"Match {i}:")
                print(path)
        else:
            print("Search string not found in the file.")

    def close_app_by_name(self, appName, Timec):

        # Calculate delay
        try:
            closeTime = datetime.strptime(Timec, "%H:%M")
        except ValueError:
            print("Invalid time format. Please use the format 'HH:MM'.")
            return

        print(f'Close time: {closeTime.time()}')

        current_time = datetime.now()
        desired_close_time = datetime.combine(current_time.date(), closeTime.time())

        if desired_close_time < current_time:
            desired_close_time += timedelta(days=1)
        delay = (desired_close_time - current_time).total_seconds()

        if delay > 0:
            print(f"System will shutdown {appName} at {desired_close_time}")
            time.sleep(delay)
            current_time = datetime.now()
            if current_time >= desired_close_time:
                for proc in psutil.process_iter():
                    try:
                        if proc.name().lower() == appName.lower():
                            print(f"{appName} has been found.")
                            proc.kill()
                            proc.terminate()
                            print(f"{appName} has been closed.")
                            # break
                    except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
                        pass
        else:
            print("Close time has already passed. Please enter a future time.")

        current_time = datetime.now().time()
        print("Current time:", current_time)

    def close_app_by_nameDuration(self, appName, duration):
        appName = appName.replace(' ', '')
        # Parse the duration string
        duration_parts = re.findall(r'(\d+)\s*(min|hour)', duration)
        total_seconds = 0
        for amount, unit in duration_parts:
            if unit == 'min':
                total_seconds += int(amount) * 60
            elif unit == 'hour':
                total_seconds += int(amount) * 3600

        # Calculate delay
        current_time = datetime.now()
        desired_close_time = current_time + timedelta(seconds=total_seconds)

        # Wait until desired close time
        delay = (desired_close_time - current_time).total_seconds()
        if delay > 0:
            print(f"System will shutdown {appName} after {duration}")
            time.sleep(delay)
            for proc in psutil.process_iter():
                try:
                    if appName.lower() in proc.name().lower():
                        print(f"{appName} has been found.")
                        proc.kill()
                        proc.terminate()
                        print(f"{appName} has been closed.")
                        # break
                except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
                    pass
            print(f"Closing {appName} after {duration}")
            # Perform action to close the application here
        else:
            print("Close time has already passed. Please enter a future time.")

    def create_alarm_window(self, hour, minute):
        alarm_root = tk.Tk()
        alarm_root.title("Alarm")
        alarm_root.geometry("500x300")
        alarm_root.configure(bg='#282c34')

        label_font = ('Times New Roman', 32, 'bold')
        alarm_label = tk.Label(alarm_root, font=label_font, text="Alarm: 00:00:00", bg='#282c34', fg='#61dafb', pady=20,
                               padx=20, borderwidth=5, relief="ridge")
        alarm_label.pack(pady=20)

        def update_label(label, hour, minute, second):
            label.config(text=f"{hour:02d}:{minute:02d}:{second:02d}")
            label.update_idletasks()

        def set_alarm(hour, minute):
            seconds = hour * 3600 + minute * 60
            while seconds > 0:
                time_pass = seconds
                minLeft = (time_pass % 3600) // 60
                secLeft = time_pass % 60
                hourLeft = time_pass // 3600
                update_label(alarm_label, hourLeft, minLeft, secLeft)
                time.sleep(1)
                seconds -= 1
                # if seconds <= 10:
                #     blink_label(alarm_label, "Alarm is about to finish!", "Alarm: 00:00:00", 1)
            alarm_label.config(text="Alarm done!")
            playsound("sound.mp3")

        def start_alarm(hour, minute):
            alarm_thread = Thread(target=set_alarm, args=(hour, minute))
            alarm_thread.start()

        start_alarm(hour, minute)
        alarm_root.mainloop()

    def shutdown_pc(self, shutdown_time):

        try:
            SDTime = datetime.strptime(shutdown_time, "%H:%M:%S").time()
            shutdown_datetime = datetime.combine(datetime.now().date(), SDTime)

            time.sleep((shutdown_datetime - datetime.now()).total_seconds())
            print("sleep is over")

            # Shutdown the PC
            print("shutdown pc now")
            subprocess.call(['shutdown', '/s'])
        except ValueError:
            print("Invalid time format. Please try again.")

    def convert_arabic_time_to_english(self, arabic_time):
        # Define a dictionary to convert Arabic numerals to English
        arabic_to_english = {
            '٠': '0',
            '١': '1',
            '٢': '2',
            '٣': '3',
            '٤': '4',
            '٥': '5',
            '٦': '6',
            '٧': '7',
            '٨': '8',
            '٩': '9'
        }

        # Convert Arabic numerals to English
        arabic_time = ''.join(arabic_to_english.get(char, char) for char in arabic_time)
        # Define patterns to match different formats of Arabic time expressions
        patterns = [
            (r'ساعتين إلا ربع', '1 hours and 45 minutes'),
            (r'ساعتين إلا ثلث', '1 hours and 40 minutes'),
            (r'ساعة إلا (\d+)', lambda match: f'00:{(60 - int(match.group(1)))}'),
            (r'الساعة (\d+):(\d+)', lambda match: f'{match.group(1)}:{match.group(2)}:00'),
            (r'الساعة (\d+)', lambda match: f'{match.group(1)}:00'),
            (r'ساعة وربع', '1 hour and 15 minutes'),
            (r'ساعة ونصف', '1 hour and 30 minutes'),
            (r'ساعة وثلث', '1 hour and 20 minutes'),
            (r'ساعة', '1 hour'),
            (r'إلا(\d+)', lambda match: f'{(60 - int(match.group(1)))} mintues'),
            (r'(\d+)ساعة و', lambda match: f'1:{match.group(1)}'),
            (r' و (\d+) دقيقة', lambda match: f'{match.group(1)} minutes'),
            (r'(\d+) ساعة و (\d+) دقيقه', lambda match: f'{match.group(1)} hours and {match.group(2)} minutes'),
            (r'(\d+) ساعة و (\d+) دقيقة', lambda match: f'{match.group(1)} hours and {match.group(2)} minutes'),
            (r'(\d+) ساعات ونصف', lambda match: f'{match.group(1)} hours and 30 minutes'),
            (r'(\d+) ساعات وثلث', lambda match: f'{match.group(1)} hours and 20 minutes'),
            (r'(\d+) ساعات وربع', lambda match: f'{match.group(1)} hours and 15 minutes'),
            (r'(\d+) ساعة', lambda match: f'{match.group(1)} hours'),
            (r'(\d+) دقيقة', lambda match: f'{match.group(1)} minutes'),
            (r'(\d+) ساعة', lambda match: f'{match.group(1)} hours'),
            (r'(\d+) دقيقه', lambda match: f'{match.group(1)} minutes'),
            (r'(\d+) ساعة و (\d+) دقيقة', lambda match: f'{match.group(1)} hours and {match.group(2)} minutes'),
            (r'(\d+) ساعة', lambda match: f'{match.group(1)} hours'),
            (r'(\d+)\s*ساعات', lambda match: f'{match.group(1)} hours'),
            (r'ساعتين', '2 hours'),
            (r'ساعتين ونصف', '2 hours and 30 minutes'),
            (r'ساعتين وثلث', '2 hours and 20 minutes'),
            (r'ساعتين وربع', '2 hours and 15 minutes'),
            (r'(\d+) دقيقة', lambda match: f'{match.group(1)} minutes'),
            (r'(\d+) دقيقه', lambda match: f'{match.group(1)} minutes'),
            (r'(\d+) دقائق', lambda match: f'{match.group(1)} minutes'),
            (r'نصف', '30 minutes'),
            (r'ربع', '15 minutes'),
            (r'ثلث', '20 minutes'),
            (r'و', 'and'),
        ]

        # Iterate through patterns and apply substitution
        for pattern, repl in patterns:
            if callable(repl):
                arabic_time = re.sub(pattern, repl, arabic_time)
            else:
                arabic_time = re.sub(pattern, repl, arabic_time)

        # Convert Arabic numerals to English
        arabic_time = ''.join(arabic_to_english.get(char, char) for char in arabic_time)

        return arabic_time

    def restart_pc_at_specific_time(self, hour, minute):
        # Schedule restart task
        schedule.every().day.at(f"{hour:02d}:{minute:02d}").do(self.restart_pc)

        # Infinite loop to keep the script running
        while True:
            schedule.run_pending()
            time.sleep(1)

    def restart_pc(self):
        print("Restarting PC...")
        os.system("shutdown /r /t 1")  # On Windows, restarts the PC after 1 second delay

    def restart_pc_in(self, delay_seconds):
        print(f"Restarting PC in {delay_seconds} seconds...")
        time.sleep(delay_seconds)
        os.system("shutdown /r /t 1")  # On Windows, restarts the PC after 1 second delay

    def create_timer_window(self, hour, minute):
        timer_root = tk.Tk()
        timer_root.title("Timer")
        timer_root.geometry("500x400")
        timer_root.configure(bg='#282c34')

        label_font = ('Times New Roman', 32, 'bold')
        timer_label = tk.Label(timer_root, font=label_font, text="Timer: 00:00:00", bg='#282c34', fg='#61dafb', pady=10,
                               padx=20, borderwidth=5, relief="ridge")
        timer_label.pack(pady=10)

        def update_label(label, hour, minute, second):
            label.config(text=f"Timer: {hour:02d}:{minute:02d}:{second:02d}")
            label.update_idletasks()

        def timer(hour, minute):
            seconds = hour * 3600 + minute * 60
            while seconds > 0:
                hourLeft = seconds // 3600
                minLeft = (seconds % 3600) // 60
                secLeft = seconds % 60
                update_label(timer_label, hourLeft, minLeft, secLeft)
                time.sleep(1)
                seconds -= 1
                # if seconds <= 10:
                #     blink_label(timer_label, "Timer is about to finish!", f"Timer: {hourLeft:02d}:{minLeft:02d}:{secLeft:02d}", 5)
            timer_label.config(text="Timer done!")
            pygame.mixer.init()
            pygame.mixer.music.load("sound.mp3")
            pygame.mixer.music.play()

        def start_timer(hour, minute):
            timer_thread = Thread(target=timer, args=(hour, minute))
            timer_thread.start()

        start_timer(hour, minute)
        timer_root.mainloop()

    def sleep_pc_at_specific_time(self, hour, minute):
        # Schedule sleep task
        schedule.every().day.at(f"{hour:02d}:{minute:02d}").do(self.sleep_pc)

        # Infinite loop to keep the script running
        while True:
            schedule.run_pending()
            time.sleep(1)

    def sleep_pc(self):
        print("Putting PC to sleep...")
        os.system("rundll32.exe powrprof.dll,SetSuspendState 0,1,0")  # Puts PC to sleep

    def write_to_notepad_and_save(self, text, file_path):
        # Join the directory path and filename

        full_file_path = os.path.join(file_path, "note1.txt")

        # Write the text to the specified file path
        with open(full_file_path, "w", encoding='utf-8') as file:
            file.write(text)

        # Open Notepad with the specified file path
        subprocess.Popen(["notepad.exe", full_file_path]).wait()

        # Close Notepad after a delay to ensure it has enough time to load the file
        time.sleep(1)

        # Save and close the file
        subprocess.Popen(["notepad.exe", "/pt", full_file_path, full_file_path]).wait()


class Models:
    def __init__(self):
        self.support = SupportModelFunctions()
        self.outputFilePath = "nb_output\\output.txt"
        # self.device = "cuda:0" if torch.cuda.is_available() else "cpu"
        # self.torch_dtype = torch.float16 if torch.cuda.is_available() else torch.float32

        # whisper_path = 'whisperModel'

        # classification_model_path = 'Classification_Model/arabic-text-classification-model'
        # classification_tokenizer_path = 'Classification_Model/arabic-text-classification-model'

        # NER_model_path = 'NER_Model/Model'
        # NER_tokenizer = 'NER_Model/ModelTokenizer'

        # self.whisperModel = WhisperForConditionalGeneration.from_pretrained(whisper_path)
        # self.whisperTokenizer = WhisperTokenizer.from_pretrained(whisper_path)
        # self.whisper_feature_extractor = WhisperFeatureExtractor.from_pretrained("openai/whisper-medium")

        # self.classificationTokenizer = AutoTokenizer.from_pretrained(classification_tokenizer_path)
        # self.classificationModel = AutoModelForSequenceClassification.from_pretrained(classification_model_path)

        # self.NER_model = AutoModelForTokenClassification.from_pretrained(NER_model_path)
        # self.NER_tokenizer = BertTokenizerFast.from_pretrained(NER_tokenizer)

    def arabic_map(self, time):
        # print(time)
        time_map = {
            'دقيقه': '1 min',
            'دقيقة': '1 min',
            'ودقيقه': ':1',
            'ودقيقة': ':1',
            'و': ':',
            'دقيقاتان': '2 min',
            'دقيقتين': '2 min',
            'دقيقتان': '2 min',
            'وربع': ':15',
            'ونصف': ':30',
            'وثلث': ':20',
            'وتلت': ':20',
            'ساعه': '1 hour',
            'ساعة': '1 hour',
        }
        words = time.split()
        result = ''
        # print(len(words))
        if len(words) > 1:
            time_map['ساعه'] = '1'
            time_map['ساعة'] = '1'
            for i in words:
                if i in time_map:
                    if result != '' and result[-1].isdigit() and (
                            i == 'ساعه' or i == 'دقيقه' or i == 'ساعة' or i == 'دقيقة'):
                        result += f' {i}'
                    else:
                        result += time_map[i]
                else:
                    if i.isdigit() or (not i[0].isdigit() and i[1].isdigit()):
                        if not i[0].isdigit():
                            char = time_map[i[0]]
                            i = char + i[1:]
                        result += i

            return result
        else:
            if time in time_map:
                result = time_map[time]
            else:
                result = time
            return result

    def speechToText(self, voice_path):

        pipe = pipeline(
            "automatic-speech-recognition",
            model=self.whisperModel,
            tokenizer=self.whisperTokenizer,
            feature_extractor=self.whisper_feature_extractor,
            max_new_tokens=128,
            chunk_length_s=30,
            batch_size=16,
            return_timestamps=True,
            torch_dtype=self.torch_dtype,
            device=self.device,
        )

        # Update the sample to be an audio data
        sample = open(f"{voice_path}", "rb").read()

        result = pipe(sample, generate_kwargs={"language": "arabic"})

        return result['text']

    def classify(self, text):
        # Tokenize the input text and move tensors to the GPU if available
        inputs = self.classificationTokenizer(text, padding=True, truncation=True, max_length=512, return_tensors="pt")

        # Get model output (logits)
        outputs = self.classificationModel(**inputs)

        probs = outputs[0].softmax(1)

        pred_label_idx = probs.argmax()
        pred_label = self.classificationModel.config.id2label[pred_label_idx.item()]

        return pred_label

    def get_ner_entities(self, text):
        nlp = pipeline("ner", model=self.NER_model, tokenizer=self.NER_tokenizer)

        ner_results = nlp(text)

        # Extract entities and their corresponding labels
        entities = defaultdict(list)
        current_word = ""
        current_labels = []
        for result in ner_results:
            # Handle subwords by concatenating them back into complete words
            word = result['word']
            if word.startswith('##'):
                current_word += word[2:]
            else:
                if current_word:  # If there was a previous word, add it with its labels
                    entities[current_word].extend(current_labels)
                    current_word = ""  # Reset current_word for the next word
                    current_labels = []  # Reset current_labels for the next word
                current_word = word
                current_labels.append(result['entity'])

        # Add the last word with its labels
        if current_word:
            entities[current_word].extend(current_labels)

        # # Print entities and their labels
        # for word, labels in entities.items():
        #     # label = label_encoder.transform(labels)
        #     print(f"Word: {word}, Labels: {', '.join(labels)}")
        return entities

    def run(self, save_path):
        # print(f'voice_path : {voice_path}')
        # # Handle whisper ##
        # text = self.speechToText(voice_path)
        # print(f'text from speech : {text}')
        ## ================================================ ##
        kaggle = kaggleAPI()
        className = ""
        entities = {}

        # Open and read the file
        with open(self.outputFilePath, "r", encoding="utf-8") as f:
            lines = f.readlines()

        # Assign the first line to className
        className = lines[0].strip()
        print(f'Class Name : {className}')

        # Parse the remaining lines into the entities dictionary
        for line in lines[1:]:
            # Remove any leading/trailing whitespace and split the line into word and labels
            line = line.strip()
            if line:
                # Extract the word and labels from the line
                word, labels = line.split(", Labels: ")
                word = word.replace("Word: ", "").strip()
                labels = labels.split(", ")
                entities[word] = labels
        # className = self.classify(text)
        # print(f'class Name : {className}')
        # entities = self.get_ner_entities(text)
        for word, labels in entities.items():
            label = str(labels[0]) if isinstance(labels, list) and len(labels) > 0 else str(labels)
            print(label)
        if className == 'بحث':
            fileFolder = ''
            typeToSearch = ''
            for word, labels in entities.items():
                label = str(labels[0]) if isinstance(labels, list) and len(labels) > 0 else str(labels)
                if word == '.':
                    continue
                if label == 'اسم العنصر':
                    print(word)
                    fileFolder += f' {word}'
                elif label == 'نوع العنصر':
                    typeToSearch = word

            print(f'file or folder name : {fileFolder}')
            print(f'type to search about : {typeToSearch}')
            self.support.get_file_folder(fileFolder.strip())
        elif className == 'غلق':
            element = ''
            duration = ''
            timeToapply = ''
            for word, labels in entities.items():
                label = str(labels[0]) if isinstance(labels, list) and len(labels) > 0 else str(labels)
                if label == 'اسم العنصر':
                    element += f' {word}'
                elif label == 'فترة':
                    duration += f' {word}'
                elif label == 'وقت':
                    timeToapply += f' {word}'

            print(f"element to close : {element}")
            print(f'duration : {duration}')
            print(f'time : {timeToapply}')
            if 'الساعه' in timeToapply or 'الساعة' in timeToapply:
                duration = ''
            if duration:
                print(f'english time : {self.arabic_map(duration.strip())}')
                duration = self.arabic_map(duration.strip())
                self.support.close_app_by_nameDuration(element.strip(), duration)
            if timeToapply:
                print(f'english time : {self.arabic_map(timeToapply.strip())}')
                timeToapply = self.arabic_map(timeToapply.strip())
                self.support.close_app_by_name(element.strip(), timeToapply)
        elif className == 'اعادة تشغيل الجهاز':
            element = ''
            duration = ''
            timeToapply = ''
            for word, labels in entities.items():
                label = str(labels[0]) if isinstance(labels, list) and len(labels) > 0 else str(labels)
                if label == 'اسم العنصر':
                    element = word
                elif label == 'فترة':
                    duration += f' {word}'
                elif label == 'وقت':
                    timeToapply += f' {word}'

            print(f"element to restart : {element}")
            print(f'duration : {duration}')
            print(f'time : {timeToapply}')
            if duration:
                print(f'english time : {self.arabic_map(duration.strip())}')
                duration = self.arabic_map(duration.strip())
                hour = 0
                minute = 0
                if 'hour' in duration or ':' in duration or 'ساعه' in duration or 'ساعة' in duration:
                    if 'hour' in duration:
                        index = duration.find('hour')
                        if index != -1:
                            # Get the substring from the start to the index
                            hour = duration[:index - 1]
                            print(f'substring : {hour}')
                    elif ':' in duration:
                        index = duration.find(':')
                        if index != -1:
                            # Get the substring from the start to the index
                            hour = duration[:index]
                            print(f'substring : {hour}')
                    elif 'ساعه' in duration:
                        index = duration.find('ساعة')
                        if index != -1:
                            # Get the substring from the start to the index
                            hour = duration[:index - 1]
                            print(f'substring : {hour}')
                    elif 'ساعة' in duration:
                        index = duration.find('ساعه')
                        if index != -1:
                            # Get the substring from the start to the index
                            hour = duration[:index - 1]
                            print(f'substring : {hour}')

                if 'min' in duration or ':' in duration or 'دقيقه' in duration or 'دقيقة' in duration:
                    if 'min' in duration:
                        index = duration.find('min')
                        if index != -1:
                            # Get the substring from the start to the index
                            minute = duration[:index - 1]
                            print(f'substring : {minute}')
                    elif ':' in duration:
                        index = duration.find(':')
                        if index != -1:
                            # Get the substring from the start to the index
                            minute = duration[:index]
                            print(f'substring : {minute}')
                    elif 'دقيقه' in duration:
                        index = duration.find('دقيقه')
                        if index != -1:
                            # Get the substring from the start to the index
                            minute = duration[:index - 1]
                            print(f'substring : {minute}')
                    elif 'دقيقة' in duration:
                        index = duration.find('دقيقة')
                        if index != -1:
                            # Get the substring from the start to the index
                            minute = duration[:index - 1]
                            print(f'substring : {minute}')

                now = datetime.now()

                # Extract the hour and minute
                current_hour = now.hour
                current_minute = now.minute

                while (minute > 59):
                    minute %= 60
                    hour += 1

                print(f'{current_hour + int(hour)} : {current_minute + int(minute)}')
                self.support.restart_pc_at_specific_time(hour=(current_hour + int(hour)) % 24,
                                                         minute=current_minute + int(minute))
            elif timeToapply:
                print(f'english time : {self.arabic_map(timeToapply.strip())}')
                timeToapply = self.arabic_map(timeToapply.strip())
                hour = 0
                minute = 0
                if 'الساعه' in timeToapply or 'الساعة' in timeToapply or ':' in timeToapply:
                    if 'الساعه' in timeToapply:
                        last_index = timeToapply.rfind('الساعه')
                        end_index = last_index + 2
                        while end_index < len(timeToapply) and timeToapply[end_index] != ' ':
                            end_index += 1
                        hour = timeToapply[last_index + 2:end_index]
                    elif 'الساعة' in timeToapply:
                        last_index = timeToapply.rfind('الساعه')
                        end_index = last_index + 2
                        while end_index < len(timeToapply) and timeToapply[end_index] != ' ':
                            end_index += 1
                        hour = timeToapply[last_index + 2:end_index]
                    elif ':' in timeToapply:
                        index = timeToapply.find(':')
                        hour = timeToapply[:index]
                        minute = timeToapply[index + 1:]
                elif len(timeToapply) > 0:
                    hour = timeToapply
                print(f"hour : {hour}, minute : {minute}")
                self.support.restart_pc_at_specific_time(int(hour), int(minute))
        elif className == 'ضبط':
            element = ''
            duration = ''
            timeToapply = ''
            for word, labels in entities.items():
                label = str(labels[0]) if isinstance(labels, list) and len(labels) > 0 else str(labels)
                if label == 'اسم العنصر':
                    element = word
                elif label == 'فترة':
                    duration += f' {word}'
                elif label == 'وقت':
                    timeToapply += f' {word}'

            print(f"element to set : {element}")
            print(f'duration : {duration}')
            print(f'time : {timeToapply}')

            if duration:
                print(f'english time : {self.arabic_map(duration.strip())}')
                duration = self.arabic_map(duration.strip())
                hour = 0
                minute = 0
                if 'hour' in duration or ':' in duration or 'ساعه' in duration or 'ساعة' in duration:
                    if 'hour' in duration:
                        index = duration.find('hour')
                        if index != -1:
                            # Get the substring from the start to the index
                            hour = duration[:index - 1]
                            print(f'substring : {hour}')
                    elif ':' in duration:
                        index = duration.find(':')
                        if index != -1:
                            # Get the substring from the start to the index
                            hour = duration[:index]
                            print(f'substring : {hour}')
                    elif 'ساعه' in duration:
                        index = duration.find('ساعة')
                        if index != -1:
                            # Get the substring from the start to the index
                            hour = duration[:index - 1]
                            print(f'substring : {hour}')
                    elif 'ساعة' in duration:
                        index = duration.find('ساعه')
                        if index != -1:
                            # Get the substring from the start to the index
                            hour = duration[:index - 1]
                            print(f'substring : {hour}')

                if 'min' in duration or ':' in duration or 'دقيقه' in duration or 'دقيقة' in duration:
                    if 'min' in duration:
                        index = duration.find('min')
                        if index != -1:
                            # Get the substring from the start to the index
                            minute = duration[:index - 1]
                            print(f'substring : {minute}')
                    elif ':' in duration:
                        index = duration.find(':')
                        if index != -1:
                            # Get the substring from the start to the index
                            minute = duration[:index]
                            print(f'substring : {minute}')
                    elif 'دقيقه' in duration:
                        index = duration.find('دقيقه')
                        if index != -1:
                            # Get the substring from the start to the index
                            minute = duration[:index - 1]
                            print(f'substring : {minute}')
                    elif 'دقيقة' in duration:
                        index = duration.find('دقيقة')
                        if index != -1:
                            # Get the substring from the start to the index
                            minute = duration[:index - 1]
                            print(f'substring : {minute}')

                while (int(minute) > 59):
                    minute %= 60
                    hour += 1

                print(f'{int(hour)} : {int(minute)}')
                self.support.create_timer_window(int(hour), int(minute))
            elif timeToapply:
                print(f'english time : {self.arabic_map(timeToapply.strip())}')
                timeToapply = self.arabic_map(timeToapply.strip())
                hour = 0
                minute = 0
                if 'الساعه' in timeToapply or 'الساعة' in timeToapply or ':' in timeToapply:
                    if 'الساعه' in timeToapply:
                        last_index = timeToapply.rfind('الساعه')
                        end_index = last_index + 2
                        while end_index < len(timeToapply) and timeToapply[end_index] != ' ':
                            end_index += 1
                        hour = timeToapply[last_index + 2:end_index]
                    elif 'الساعة' in timeToapply:
                        last_index = timeToapply.rfind('الساعه')
                        end_index = last_index + 2
                        while end_index < len(timeToapply) and timeToapply[end_index] != ' ':
                            end_index += 1
                        hour = timeToapply[last_index + 2:end_index]
                    elif ':' in timeToapply:
                        index = timeToapply.find(':')
                        hour = timeToapply[:index]
                        minute = timeToapply[index + 1:]
                elif len(timeToapply) > 0:
                    hour = timeToapply

                now = datetime.now()

                # Extract the hour and minute
                current_hour = now.hour
                current_minute = now.minute
                print(f'current hour : {current_hour}')

                if current_hour > int(hour):
                    hour = (int(hour) + 24) - current_hour
                else:
                    hour = int(hour) - current_hour

                print(f"hour : {hour}, minute : {abs(int(minute) - current_minute)}")
                self.support.create_alarm_window(hour, abs(minute - current_minute))
        elif className == 'ايقاف تشغيل الجهاز مؤقتاً':
            duration = ''
            timeToapply = ''
            for word, labels in entities.items():
                label = str(labels[0]) if isinstance(labels, list) and len(labels) > 0 else str(labels)
                if label == 'فترة':
                    duration += f' {word}'
                elif label == 'وقت':
                    timeToapply += f' {word}'

            print(f'duration to sleep after : {duration}')
            print(f'time to sleep in : {timeToapply}')

            if duration:
                print(f'english time : {self.arabic_map(duration.strip())}')
                duration = self.arabic_map(duration.strip())
                hour = 0
                minute = 0
                if 'hour' in duration or ':' in duration or 'ساعه' in duration or 'ساعة' in duration:
                    if 'hour' in duration:
                        index = duration.find('hour')
                        if index != -1:
                            # Get the substring from the start to the index
                            hour = duration[:index - 1]
                            print(f'substring : {hour}')
                    elif ':' in duration:
                        index = duration.find(':')
                        if index != -1:
                            # Get the substring from the start to the index
                            hour = duration[:index]
                            print(f'substring : {hour}')
                    elif 'ساعه' in duration:
                        index = duration.find('ساعة')
                        if index != -1:
                            # Get the substring from the start to the index
                            hour = duration[:index - 1]
                            print(f'substring : {hour}')
                    elif 'ساعة' in duration:
                        index = duration.find('ساعه')
                        if index != -1:
                            # Get the substring from the start to the index
                            hour = duration[:index - 1]
                            print(f'substring : {hour}')

                if 'min' in duration or ':' in duration or 'دقيقه' in duration or 'دقيقة' in duration:
                    if 'min' in duration:
                        index = duration.find('min')
                        if index != -1:
                            # Get the substring from the start to the index
                            minute = duration[:index - 1]
                            print(f'substring : {minute}')
                    elif ':' in duration:
                        index = duration.find(':')
                        if index != -1:
                            # Get the substring from the start to the index
                            minute = duration[:index]
                            print(f'substring : {minute}')
                    elif 'دقيقه' in duration:
                        index = duration.find('دقيقه')
                        if index != -1:
                            # Get the substring from the start to the index
                            minute = duration[:index - 1]
                            print(f'substring : {minute}')
                    elif 'دقيقة' in duration:
                        index = duration.find('دقيقة')
                        if index != -1:
                            # Get the substring from the start to the index
                            minute = duration[:index - 1]
                            print(f'substring : {minute}')

                now = datetime.now()

                # Extract the hour and minute
                current_hour = now.hour
                current_minute = now.minute

                while (minute > 59):
                    minute %= 60
                    hour += 1

                print(f'{current_hour + int(hour)} : {current_minute + int(minute)}')
                self.support.sleep_pc_at_specific_time(hour=(current_hour + int(hour)) % 24,
                                                       minute=current_minute + int(minute))
            elif timeToapply:
                print(f'english time : {self.arabic_map(timeToapply.strip())}')
                timeToapply = self.arabic_map(timeToapply.strip())
                hour = 0
                minute = 0
                if 'الساعه' in timeToapply or 'الساعة' in timeToapply or ':' in timeToapply:
                    if 'الساعه' in timeToapply:
                        last_index = timeToapply.rfind('الساعه')
                        end_index = last_index + 2
                        while end_index < len(timeToapply) and timeToapply[end_index] != ' ':
                            end_index += 1
                        hour = timeToapply[last_index + 2:end_index]
                    elif 'الساعة' in timeToapply:
                        last_index = timeToapply.rfind('الساعه')
                        end_index = last_index + 2
                        while end_index < len(timeToapply) and timeToapply[end_index] != ' ':
                            end_index += 1
                        hour = timeToapply[last_index + 2:end_index]
                    elif ':' in timeToapply:
                        index = timeToapply.find(':')
                        hour = timeToapply[:index]
                        minute = timeToapply[index + 1:]
                elif len(timeToapply) > 0:
                    hour = timeToapply
                print(f"hour : {hour}, minute : {minute}")
                self.support.sleep_pc_at_specific_time(int(hour), int(minute))
        elif className == 'اضافة ملاحظة':
            note = ''
            for word, labels in entities.items():
                label = str(labels[0]) if isinstance(labels, list) and len(labels) > 0 else str(labels)
                if label == 'الملاحظة':
                    note += f' {word}'

            print(f'Note to save is : {note}')
            self.support.write_to_notepad_and_save(note, "C:\\Users\\andre\\Desktop")


class SupportScoketFunctions:

    def get_public_ip(self):
        try:
            response = requests.get('https://httpbin.org/ip')
            if response.status_code == 200:
                data = response.json()
                return data['origin']
            else:
                print("trying to get public ip ...")
                time.sleep(0.1)
                return self.get_public_ip()
                # return "Failed to retrieve public IP"
        except Exception as e:
            print(str(e))
            print("trying to get public ip ...")
            time.sleep(1)
            return self.get_public_ip()
            # return str(e)

    def get_local_ip(self):
        try:
            # Create a socket object
            s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

            # Connect to an external server (Google's DNS server)
            s.connect(("8.8.8.8", 80))

            # Get the current local IP address
            local_ip = s.getsockname()[0]

            return local_ip
        except socket.error:
            return "Unable to determine local IP"

    def get_mac_address(self):
        # Get the MAC address using uuid module
        mac_address = ':'.join(
            ['{:02x}'.format((uuid.getnode() >> elements) & 0xff) for elements in range(0, 2 * 6, 2)][::-1])
        return mac_address

    def transfer_partition(self, target):
        # target = request.args.get('target')
        colon_index = target.find(':')

        # Check if the colon is found
        if colon_index != -1:
            # Create a new string with a backslash inserted after the colon
            target = target[:colon_index + 1] + '\\' + target[colon_index + 1:]

        if target == 'all':
            partitions = []
            for disk in psutil.disk_partitions():
                drive = disk.device
                partitions.append(drive)

            # return jsonify(partitions)
            return partitions

        else:
            directories = []
            files = []
            content = {}
            if os.path.isdir(target):
                contents = os.listdir(target)
                for item in contents:
                    item_path = os.path.join(target, item)
                    if os.path.isdir(item_path):
                        directories.append(item)
                    else:
                        files.append(item)
            content['dir'] = directories
            content['files'] = files

            # return jsonify(content)
            return content

    def keyboardLanguage(self):
        # Define necessary constants
        LANG_ENGLISH = 0x0409  # English language identifier

        # Define the structure for the return value of GetKeyboardLayout function
        class LANGID(ctypes.Structure):
            fields = [("wLanguage", ctypes.c_uint16)]

        # Retrieve the current input language
        def get_current_language():
            lang_id = ctypes.windll.user32.GetKeyboardLayout(0)
            lang_id_struct = LANGID()
            lang_id_struct.wLanguage = lang_id & 0xFFFF  # Extract the language ID
            return lang_id_struct.wLanguage

        current_language = get_current_language()

        lang = ""
        # Check if the current language is English
        if current_language == LANG_ENGLISH:
            lang = "EN"
        else:
            lang = "AR"

        return lang

    def map_coordinates(self, mobile_x, mobile_y, mobile_width, mobile_height, desktop_width, desktop_height):
        # Calculate the ratio of movement along each axis
        x_ratio = desktop_width / mobile_width
        y_ratio = desktop_height / mobile_height

        # Map the coordinates to the desktop screen
        desktop_x = int(mobile_x * x_ratio)
        desktop_y = int(mobile_y * y_ratio)

        return desktop_x, desktop_y

    def generatePassword(self):
        # Define the character set you want to use
        charset = "0123456789abcdefghijklmnopqrstuvwxyz@#$!?&"

        # Initialize a list to store the generated strings
        generated_password = ''

        # Iterate through combinations of characters
        for i in range(8):
            j = random.randint(0, len(charset) - 1)
            # while charset[j]==generated_password[len(generated_password)-1]:
            #     j = random.randint(0, len(charset) - 1)
            generated_password += charset[j]

        return generated_password

    def close_specific_app(self, process_name):
        for proc in psutil.process_iter():
            # print(f"Program name = {proc.name()}")
            if proc.name().startswith(process_name):
                # print("============================\n")
                proc.terminate()
                break

    def deleteFilesAndFolders(self, path):
        if os.path.exists(path):
            if os.path.isdir(path):
                os.rmdir(path)
                print(f"Folder '{path}' deleted successfully.")
            else:
                os.remove(path)
                print(f"File '{path}' deleted successfully.")

            return True
        else:
            print(f"File or Folder '{path}' does not exist.")
            return False

    def cut_string_at_last_occurrence(self, text, letter):
        pos = text.rfind(letter)
        if pos == -1:
            return text  # If the letter is not found, return the original string
        return text[:pos], text[pos+1:]


class Socket:
    def __init__(self):
        self.model = Models()
        self.url = "https://desktopanywhere.onrender.com"
        # self.url = "http://localhost:5000"
        self.support = SupportScoketFunctions()
        self.publicIP = self.support.get_public_ip()
        self.privateIP = self.support.get_local_ip()
        self.macAddress = self.support.get_mac_address()
        self.password = self.support.generatePassword()
        print("\n")
        print(f"publicIP: {self.publicIP}")
        print(f"privateIP: {self.privateIP}")
        print(f"macAddress: {self.macAddress}")
        print(f"password: {self.password}")
        print("\n")
        self.refresh_srever()
        self.addDeviceToServer()


    def refresh_srever(self):
        try:
            url = f"{self.url}/welcome"
            response = requests.get(url)
            if response.status_code == 200:
                print(f"Server activated successfully!, {response.status_code} \n")
            else:
                print("Error: ", response.status_code)
                time.sleep(0.5)
                self.refresh_srever()
        except Exception as e:
            # print(str(e))
            print("Error happened when trying to activate the socket server ...")
            time.sleep(1)
            self.refresh_srever()

    def addDeviceToServer(self):
        url = f"{self.url}/desktop"
        data = {
            "public_ip": self.publicIP,
            "private_ip": self.privateIP,
            "mac_address": self.macAddress
        }
        response = requests.post(url, json=data)
        if response.status_code == 200 or response.status_code == 201:
            print(f"Device added successfully!, {response.status_code} \n")
        else:
            print(f"request failed with status code: {response.status_code}\n")

    def uploadFileToServer(self, mobile_Id, path):
        print("Start Uploaded")
        url = f"{self.url}/media"
        data = { "mobile_Id": mobile_Id, }
        file = { "file": open(path, 'rb'), }
        response = requests.post(url, files=file, data=data)
        if response.status_code == 200 or response.status_code == 201:
            print(f"File uploaded successfully!, {response.status_code} \n")
            return True
        else:
            print(f"request failed with status code: {response.status_code}\n")
            return False

    def downloadFileFromServer(self, filePath, serverPath):
        downloadUrl = f'{self.url}/{serverPath}'
        req = requests.get(downloadUrl)
        with open(filePath, 'wb') as f:
            for chunk in req.iter_content(chunk_size=8192):
                if chunk:
                    f.write(chunk)

    def deleteFileFromServer(self, mobile_Id):
        url = f"{self.url}/media/{mobile_Id}"
        response = requests.delete(url)
        if response.status_code == 200:
            print(f"File deleted from server successfully!, {response.status_code} \n")
        else:
            print("Error: ", response.status_code)

    def getFileDataFromServer(self, mobile_Id, save_path):
        url = f"{self.url}/media/view/{mobile_Id}"
        response = requests.get(url)
        if response.status_code == 200:
            body = response.json()["file"]
            file_name = body["file_name"]
            path = os.path.join(save_path, file_name)
            self.downloadFileFromServer(path, body["secure_url"])
            print(f"File downloaded successfully!, {response.status_code} \n")
            self.deleteFileFromServer(mobile_Id)
            return True
        else:
            print("Error: ", response.status_code)
            return False

    def updatePartioningView(self, socket, ip, path, desktopIndexInFlutter):
        print(f"\n Path: {path} \n")
        FolderPath, FolderName = self.support.cut_string_at_last_occurrence(path, "\\")
        partitions = self.support.transfer_partition(path)
        socket.emit("event", {
            "ip": ip,  # IP
            "type": "desktop",  # mobile or desktop or web
            "target_type": "mobile",  # mobile or desktop or web
            "event": "partition",  # target event
            "message": {
                "ip": ip,
                "part": "secondary",
                "dataType": "Folder",
                "path_flag": 0,
                "componentName": FolderName,
                "target": path,
                "update": 0,
                "partitions": partitions,
                "index": desktopIndexInFlutter,
                "popScreen": True,
            },
            "eventError": "error",  # error event if target not found
            "messageError": "",
        })

    def runSocket(self):
        ip = self.publicIP

        # Create a Socket.IO client instance
        sio = socketio.Client()

        # sio.emit("event", {
        #     "ip": "192.168.1.1", # IP
        #     "type": "desktop", # mobile or desktop or web
        #     "target_type": "mobile", # mobile or desktop or web
        #     "event": "home", # target event
        #     "message": {
        #         "": "",
        #     },
        #     "eventError": "error", # error event if target not found
        #     "messageError": {
        #         "": "",
        #     },
        # })

        # Define the event handler for the 'connect' event
        @sio.event
        def connect():
            print('Connected to server')
            sio.emit('addDevice', {
                # "id": sio.sid,
                "ip": ip,
                "type": "desktop"
            })

        @sio.event
        def message(data):
            print('Message received from server:', data)

        @sio.event
        def getKeyboardLang(data):
            print("getKeyboardLang")
            lang = self.support.keyboardLanguage()
            print(f"{lang}")
            sio.emit("event", {
                "ip": ip,  # IP
                "type": "desktop",  # mobile or desktop or web
                "target_type": "mobile",  # mobile or desktop or web
                "event": "keyboardLang",  # target event
                "message": lang,
                "eventError": "error",  # error event if target not found
                "messageError": "",
            })

        @sio.event
        def keyboard_old(data):
            print('Keyboard Status received:', data)
            if data['key'] == "Enter":
                pyautogui.press('enter')
            elif data['key'] == "Delete":
                pyautogui.press('backspace')
            elif data['key'] == "Space":
                pyautogui.press('space')
            elif data['key'] == "Caps":
                pyautogui.press("capslock")
            elif data['key'] == "EN" or data['key'] == "AR":
                if data['key'] != self.support.keyboardLanguage():
                    # pyautogui.hotkey('alt', 'shift')
                    pyautogui.keyDown('alt')
                    pyautogui.keyDown('shift')
                    time.sleep(0.05)
                    pyautogui.keyUp('alt')
                    pyautogui.keyUp('shift')
            else:
                pyautogui.typewrite(data['key'])

                # pyperclip.copy(data['key'])
                # # Use PyAutoGUI to paste the text from the clipboard
                # pyautogui.hotkey('ctrl', 'v')

        @sio.event
        def keyboard(data):
            print("keyboard: ", data)
            message = data
            if len(message) > 1:
                pyautogui.press(f'{message}')
            elif message == '\n':
                # Copy the newline character to the clipboard
                pyperclip.copy('\n')
                # Use PyAutoGUI to paste the newline character
                pyautogui.hotkey('ctrl', 'v')
            else:
                pyperclip.copy(message)
                # Use PyAutoGUI to paste the text from the clipboard
                pyautogui.hotkey('ctrl', 'v')

        @sio.event
        def getPartition(data):
            print(f"getPartition: ", data["target"])
            partitions = self.support.transfer_partition(data["target"])
            data["partitions"] = partitions
            sio.emit("event", {
                "ip": ip,  # IP
                "type": "desktop",  # mobile or desktop or web
                "target_type": "mobile",  # mobile or desktop or web
                "event": "partition",  # target event
                "message": data,
                "eventError": "error",  # error event if target not found
                "messageError": "",
            })

        @sio.event
        def mouse_click(data):
            print('mouse_click: ', data)
            # x, y = pyautogui.position()
            mouse = Controller()
            if data == "Left Click":
                # pyautogui.click(x, y, button="left") # data => left or right
                mouse.click(Button.left)
            elif data == "Right Click":
                # pyautogui.click(x, y, button="right") # data => left or right
                mouse.click(Button.right)
            elif data == "Double Click":
                # pyautogui.doubleClick(x, y)
                mouse.click(Button.left)
                time.sleep(0.1)  # Optional: Add a short delay between clicks
                mouse.click(Button.left)

        @sio.event
        def mouse_move(data):
            print(f"mouse_move, X:{int(data['X'])}, Y:{int(data['Y'])}")
            # Extract the x and y coordinates from the dictionary
            mobile_x = data["X"]
            mobile_y = data["Y"]
            mobile_width = data["width"]
            mobile_height = data["height"]

            desktop_width = win32api.GetSystemMetrics(0)
            desktop_height = win32api.GetSystemMetrics(1)

            desktop_x, desktop_y = self.support.map_coordinates(mobile_x, mobile_y, mobile_width, mobile_height,
                                                                desktop_width,
                                                                desktop_height)

            mouse = Controller()
            if data["touchpad"] == 0:
                # pyautogui.moveTo(desktop_x, desktop_y, duration=0.1)
                mouse.position = (desktop_x, desktop_y)
            else:
                # Get the current mouse position
                current_x, current_y = mouse.position

                # Calculate the new position by adding deltaX and deltaY
                new_x = current_x + desktop_x
                new_y = current_y + desktop_y

                # Move the mouse cursor to the new position
                mouse.position = (new_x, new_y)

        @sio.event
        def getPassword(data):
            print("getPassword")
            sio.emit("event", {
                "ip": ip,  # IP
                "type": "desktop",  # mobile or desktop or web
                "target_type": "web",  # mobile or desktop or web
                "event": "password",  # target event
                "message": self.password,
                "eventError": "error",  # error event if target not found
                "messageError": "",
            })

        @sio.event
        def refreshPassword(data):
            print("refreshPassword")
            self.password = self.support.generatePassword()
            print(f"New Password: {self.password}")
            sio.emit("event", {
                "ip": ip,  # IP
                "type": "desktop",  # mobile or desktop or web
                "target_type": "web",  # mobile or desktop or web
                "event": "password",  # target event
                "message": self.password,
                "eventError": "error",  # error event if target not found
                "messageError": "",
            })

        @sio.event
        def checkPassword(data):
            print("checkPassword: ", data["password"])
            result = ""
            valid = False
            # valid = True
            msg = {}
            if self.password == data["password"]:
                result = "You have Successfully paired to this device."
                valid = True
                msg["mac"] = self.macAddress
            else:
                result = "In-valid password"

            msg["message"] = result
            msg["valid"] = valid

            sio.emit("event", {
                "ip": ip,
                "type": "desktop",
                "target_type": "mobile",
                "event": "password",
                "message": msg,
                # "message": {
                #     "message": result,
                #     "valid": valid
                # },
                "eventError": "error",
                "messageError": "",
            })

        @sio.event
        def getDimensions(data):
            print("getDimensions \n")
            desktop_width = win32api.GetSystemMetrics(0)
            desktop_height = win32api.GetSystemMetrics(1)
            sio.emit("event", {
                "ip": ip,  # IP
                "type": "desktop",  # mobile or desktop or web
                "target_type": "mobile",  # mobile or desktop or web
                "event": "desktopDimensions",  # target event
                "message": {
                    "width": desktop_width,
                    "height": desktop_height
                },
                "eventError": "error",  # error event if target not found
                "messageError": "",
            })

        @sio.event
        def voice(data):
            print("voice")
            voice_file = data

            # Save the file to a specified directory
            save_dir = 'datasets'
            # save_dir = 'saved_voices_socket'
            if not os.path.exists(save_dir):
                os.makedirs(save_dir)

            save_path = os.path.join(save_dir, "received_audio.wav")
            with open(save_path, 'wb') as f:
                f.write(bytearray(voice_file))
            print(f"Audio saved to: {save_path}")

            msg = "Command Done"
            flag = True
            sio.emit("event", {
                "ip": ip,  # IP
                "type": "desktop",  # mobile or desktop or web
                "target_type": "mobile",  # mobile or desktop or web
                "event": "voiceArrived",  # target event
                "message": {
                    "ip": ip,
                    "message": msg,
                    "flag": flag,
                },
                "eventError": "error",  # error event if target not found
                "messageError": "",
            })

            self.model.run(save_path)

        @sio.event
        def deleteFileOrFolder(data):
            print("delete File Or Folder")
            print(data)
            delete_path = os.path.join(data["path"], data["deleted_name"])
            type = "folder" if os.path.isdir(delete_path) else "file"
            msg = f"Error, couldn't delete this {type}"
            isDeleted = self.support.deleteFilesAndFolders(delete_path)
            if isDeleted:
                msg = "F" + type[1:] + " deleted successfully"

            print(f"{msg} \n\n")
            sio.emit("event", {
                "ip": ip,  # IP
                "type": "desktop",  # mobile or desktop or web
                "target_type": "mobile",  # mobile or desktop or web
                "event": "deleteResults",  # target event
                "message": {
                    "isDeleted": isDeleted,
                    "message": msg,
                    "index": data["index"],
                },
                "eventError": "error",  # error event if target not found
                "messageError": "",
            })
            print(f"finish delete {type} \n")

            if not isDeleted: return
            self.updatePartioningView(socket=sio, ip=ip, path=data["path"], desktopIndexInFlutter=data["index"])
            print(f"Updated View after delete")

        @sio.event
        def createFolder(data):
            print(data)
            folder_name = data["folder_name"]
            path = data["path"]
            new_folder_path = os.path.join(path, folder_name)

            msg = ""
            isCreated = False
            try:
                os.mkdir(new_folder_path)
                isCreated = True
                msg = f"Folder '{folder_name}' created at '{path}' successfully"
            except FileExistsError:
                msg = f"Folder '{folder_name}' already exists at '{path}'"
            except OSError as e:
                msg = f"Error: {e}"

            print(f"msg: {msg} \n\n")
            sio.emit("event", {
                "ip": ip,  # IP
                "type": "desktop",  # mobile or desktop or web
                "target_type": "mobile",  # mobile or desktop or web
                "event": "createFolderResults",  # target event
                "message": {
                    "isCreated": isCreated,
                    "message": msg
                },
                "eventError": "error",  # error event if target not found
                "messageError": "",
            })
            print(f"finished create {type} \n")
            if not isCreated: return
            self.updatePartioningView(socket=sio, ip=ip, path=data["path"], desktopIndexInFlutter=data["index"])
            print(f"Updated View after created")

        @sio.event
        def uploadFile(data):
            print("upload File")
            print(data)
            path = data["path"]
            file_size = os.path.getsize(path)
            isUploaded = 0
            msg = "Error, file size more than 50MB"
            if file_size <= 52428800:
                isUploaded = self.uploadFileToServer(data["deviceId"], path)
                msg = "File copy successfully"

            sio.emit("event", {
                "ip": ip,  # IP
                "type": "desktop",  # mobile or desktop or web
                "target_type": "mobile",  # mobile or desktop or web
                "event": "uploadResults",  # target event
                "message": {
                    "isUploaded": isUploaded,
                    "message": msg,
                    "forMobile": data["forMobile"] if data.__contains__("forMobile") else False,
                    "directoryPathInMobile": data["directoryPathInMobile"] if data.__contains__("directoryPathInMobile") else "",
                },
                "eventError": "error",  # error event if target not found
                "messageError": "",
            })
            # print("finish upload File \n")
            print(f" {msg} \n\n")

        @sio.event
        def downloadFile(data):
            print("download File")
            print(data)
            mobileId = data["deviceId"]
            save_path = data["path"]
            isDownloaded = self.getFileDataFromServer(mobileId, save_path)
            msg = "Error, file couldn't paste"
            if isDownloaded:
                msg = "File paste successfully"

            print(f" {msg} \n\n")

            sio.emit("event", {
                "ip": ip,  # IP
                "type": "desktop",  # mobile or desktop or web
                "target_type": "mobile",  # mobile or desktop or web
                "event": "downloadResults",  # target event
                "message": {
                    "isDownloaded": isDownloaded,
                    "message": msg
                },
                "eventError": "error",  # error event if target not found
                "messageError": "",
            })
            print("finish download File")

            if not isDownloaded: return
            self.updatePartioningView(socket=sio, ip=ip, path=data["path"], desktopIndexInFlutter=data["index"])
            print(f"Updated View after paste")

        # Define the event handler for the 'disconnect' event
        @sio.event
        def disconnect():
            print('Disconnected from server \n')
            self.refresh_srever()

        # Connect to the Socket.IO server
        sio.connect(self.url)

        while True:
            # Wait for events
            sio.sleep()

        # Disconnect from the server
        # sio.disconnect()



def runDesktopGUI():
    script_path = os.path.abspath(__file__)  # Get the absolute path of the current Python script
    project_path = os.path.dirname(script_path)  # Get the directory containing the script
    # project_path += "\\desktop_anywhere_web-win32-x64\\desktop_anywhere_web.exe"
    project_path += "\\DesktopAnyWhere-win32-x64"
    if not os.path.exists(project_path):
        subprocess.run("npm install -g nativefier", shell=True, text=True, capture_output=True)
        subprocess.run("nativefier \"https://desktopanywhere.onrender.com\" -n \"DesktopAnyWhere\"", shell=True,
                       text=True, capture_output=True)
        print("\nGUI App Created Successfully! \n")

    # print(project_path)
    project_path += "\\DesktopAnyWhere.exe"
    subprocess.Popen(f'"{project_path}"')




if __name__ == '__main__':
    soc = Socket()
    socket_process = multiprocessing.Process(target=soc.runSocket)
    desktop_process = multiprocessing.Process(target=runDesktopGUI)

    socket_process.start()
    desktop_process.start()

    socket_process.join()
    desktop_process.join()


    # get_all_paths()
    # model = Models()
    #
    # # model.run('saved_voices_socket\\received_audio.wav')
    # model.get_file_folder('welcome back pro')