<!-- # Desktop AnyWhere -->


![logo-no-background](https://github.com/user-attachments/assets/94c56387-f57c-4b1d-bc19-f1f098b61207)

<br>

Desktop Anywhere is a unified software system with mobile and desktop applications that allows seamless remote control of personal computers via touchpad, keyboard, and voice commands in Arabic, with automatic device pairing and high accuracy.





<br>



## Table of Contents

- [ Introduction. ](#Introduction)
- [ Features. ](#Features)
- [ Demo Video. ](#Demo_Video)
- [ Technologies Used & Dependencies. ](#Technologies_Used)
- [ System Architecture. ](#Project_Structure)
- [ Dataset Description. ](#Dataset_Description)
- [ Feedback and Contributing. ](#Feedback_Contributing)
- [ License. ](#License)




<a id="Introduction"></a>

<br>

## Introduction
It is a software which developed as a comprehensive and integrated system consisting of two interconnected components: a mobile application and a desktop application communicating through a server. Desktop Anywhere is developed to enable users to access and control multiple personal desktop computers remotely. It aims to provide a seamless experience for users to interact with their desktop screens, manage files, execute tasks through virtual touchpad and keyboard, and utilize voice commands in Arabic, which is done by more than 95% accuracy, all through their mobile devices which will have the ability to be automatically connected to all paired devices without authentication. The primary goal is to bridge the gap between devices and redefine remote interactions, enhancing convenience, efficiency, and accessibility in the realm of digital connectivity. for more details check our  [Documentation](Documentations/Desktop%20Anywhere%20Documentation.pdf)




<a id="Features"></a>

<br>

## Features
- **File Management:** Provides access to desktop partitions from the mobile app, allowing users to copy files between desktops, save files to the mobile device, delete, and create folders.
- **Live Screen Sharing:** Allows users to view and control their desktop screen in real time through the mobile app.
- **Virtual Touchpad and keyboard:** Enables users to use their mobile device as a touchpad and keyboard for their desktop.
- **Autoconnection:** Automatically connects to paired devices without authentication after the initial pairing.
- **Multiple Desktops Access:** Supports connecting to and controlling multiple desktops simultaneously from the mobile app.
- **Arabic Voice commands:** Implements specific voice commands in Arabic for functionalities such as:
    - **Search:** Search for files or folders on the desktop.
    - **Set:** Set an alarm or stopwatch on the desktop.
    - **Add Note:** Add notes on the desktop.
    - **Close:** Schedule shutdowns or close specific running applications.
    - **Restart:** Schedule desktop restarts.
    - **Sleep:** Schedule putting the desktop in sleep mode.








<a id="Demo_Video"></a>

<br>

## Demo Video


https://github.com/user-attachments/assets/f3caf58c-18fc-4758-92b1-3cfbf1570fd9













<a id="Technologies_Used"></a>

<br>


## Technologies Used & Dependencies
- **Node.js:** A server-side JavaScript runtime used to build fast and scalable network applications.
- **Express:** A minimal and flexible Node.js web application framework that simplifies API development.
- **MongoDB:** A NoSQL database used for efficient and flexible data storage.
- **Multer:** A media management platform for uploading, storing, and delivering images and other media.
- **Socket IO:** A library that enables real-time, bidirectional communication between web clients and servers.
- **WebRTC:** Web Real-Time Communication is a technology that enables real-time audio, video, and data sharing between web browsers and mobile applications without requiring plugins or additional software.
- **Flutter:** An open-source UI framework developed by Google for building natively compiled applications for mobile, web, and desktop from a single codebase.
- **Python:** A high-level, interpreted programming language known for its readability and versatility.




<a id="Project_Structure"></a>

<br>

## Project Structure & Architecture

[Mobile App]: https://github.com/Hossam-H22/DesktopAnyWhere_GP/tree/master/Mobile%20Application/Desktop_Anywhere
[Desktop App]: https://github.com/Hossam-H22/DesktopAnyWhere_GP/tree/master/Desktop%20Application
[Server]: https://github.com/Hossam-H22/Desktop_Anywhere_Server


|     [Server]     |   [Desktop App]   |   [Mobile App]   |
|------------------|-------------------|------------------|

![Picture1](https://github.com/user-attachments/assets/07441087-3af1-4efe-8385-83d09a936634)





<!-- ![image](https://github.com/user-attachments/assets/2d330b79-cdb2-4424-9730-15c9400ec3d8) -->

<!-- ![image](https://github.com/user-attachments/assets/3d881d91-2f43-45ba-8a81-32c4189a2e6c) -->

<!-- ![image](https://github.com/user-attachments/assets/c90f1982-b299-4ab0-97aa-ce3a0f095c2c) -->





<br>

<a id="Dataset_Description"></a>

## Dataset Description  - [Dataset](Dataset/Full-Balanced-version-Numeric.xlsx)
#### Dataset Commands:
- Search: The user can search for a file/folder on his desktop.
- Set: The user can set the alarm or the stopwatch on his desktop.
- Add Note: The user can add notes on his desktop device.
- Close: The user can schedule shutting down the desktop or closing specific running apps.
- Restart: The user can schedule restarting the desktop.
- Sleep: The user can schedule putting the desktop on sleep mode.

#### Dataset generation and evolution:
- number of created records = **1932**
- number of created rows = **1872**
- number of created classes = **6**
- number of created entities = **3225**
    - Entities distributed among 5 categories:
        - Time: **11.45%**
        - Period: **27.34%**
        - Note: **8.1%**
        - Name: **41.85%**
        - Type: **11.25%**


#### Sample of Dataset:
![image](https://github.com/user-attachments/assets/84f878b8-0dda-4210-8629-142dd8a5a9ba)






<a id="Feedback_Contributing"></a>

<br>

## Feedback and Contributing
I'm excited to hear your <u><a href="https://forms.gle/mUQJdnGPey1atnzp9" target="_blank">feedback</a></u> and discuss potential collaborations and if you'd like to contribute, please fork the repository, make your changes, and submit a pull request.







<a id="License"></a>

<br>

## License
This project is licensed under the [MIT license](LICENSE).


<br>






