# Mobile Application for Surgical Robot Teleoperation

##### Source code for **[Feasibility of Mobile Application for Surgical Robot Teleoperation](https://doi.org/10.31256/HSMR2023.63)**

## 1. Introduction

This mobile application allows a user to teleoperate a robot (or a simulation of a robot) using augmented reality. Rather than control the robot using a standard controller or through buttons on the phone screen, the robot is controlled through the movement of the phone itself, enabled by world tracking. The application is built using Swift and Objective C and sends the 6D pose of the phone in local space to a specified IP address. The server can then parse the data and teleoperate the robot or simulation accordingly.

## 2. Featured Project

This project has been used to teleoperate a 7 DOF surgical robot for a research project, targeting low-cost simulation-based surgical robotics training, surgical robotics training for clinicians in low-resource environments, and researchers who similarly do not have access to the proper equipment. See the [full project](https://doi.org/10.31256/HSMR2023.63) for more details.

## 3. Installation

3.1 Clone the repository

3.2. Open the project in Xcode. You require a Mac for this.

3.3. Run the application on an iPhone. It will not work on a simulator as it requires world tracking.

## 4. Usage

4.1. Open the application

4.2. Enter the IP address of the server

4.3. Choose the right or left PSM (Patient Side Manipulator) to control

4.4. Start teleoperating the robot by moving the phone

## 5. Understanding Message Format

The message should be formatted as a JSON String and should contain the following arguments

- **camera** String: Indicates if the transformation should manipulate the camera or the PSM. Accepted values are "true" and "false"
- **transformation** String: Indicates if the transformation includes translation details. Accepted values are "true" and "false"
- **psm** String: Indicates which psm in the scene should be manipulated. Accepted values are "left" and "right"
- **x** Double: Desired position of psm on the x-axis
- **y** Double: Desired position of psm on the y-axis
- **z** Double: Desired position of psm on the z-axis
- **roll** Double: Desired roll of psm or camera
- **pitch** Double: Desired pitch of psm or camera
- **yaw** Double: Desired yaw of psm or camera
- **insert** Double: Desired insertion value of camera (only used for camera movement)

An example packet message (unencoded) with every argument is

```
'{"x": 1.000, "y": 1.000, "z": 1.000, "roll": 1.000, "pitch": 1.000, "yaw": 1.000, "end_effector": 0.5, "camera": "false", "transformation": "true", "psm": "right", "insert": 0.05}'
```

If the single quote solution does not work, then use `\"` to represent a quotation mark in JSON string

```
"{\"x\": 1.000, \"y\": 1.000, \"z\": 1.000, \"roll\": 1.000, \"pitch\": 1.000, \"yaw\": 1.000, \"end_effector\": 0.5, \"camera\": \"false\", \"transformation\": \"true\", \"psm\": \"right\", \"insert\": 0.05}"
```

However, only a few arguments are necessary for each use case. Collect and send only what is necessary for efficiency purposes.

### 5.1 Transformation

Example JSON String for Transformation

```
'{"x": 1.000, "y": 1.000, "z": 1.000, "roll": 1.000, "pitch": 1.000, "yaw": 1.000, "end_effector": 0.5, "camera": "false", "transformation": "true", "psm": "right"}'
```

### 5.2 Rotation + End Effector

Example JSON String for Rotation

```
'{"roll": 1.000, "pitch": 1.000, "yaw": 1.000, "end_effector": 0.5, "camera": "false", "transformation": "false", "psm": "right"}'
```

### 5.3 Camera

```
'{"roll": 1.000, "pitch": 1.000, "yaw": 1.000, "camera": "true"}'
```

## 6. Server

See this [code sample](https://github.com/surgical-robotics-ai/surgical_robotics_challenge/tree/master/scripts/surgical_robotics_challenge/examples/socket_based_control) of a server that receives the JSON string and parses it to control a robot. This sample was specifically created for the Surgical Robotics AI Challenge, and as such, is tailored to work with a simulation of a surgical robot created in the [AMBF](https://github.com/WPI-AIM/ambf) environment. It can be easily modified to work with any other robot or simulation.

## 7. Citation

If you find this work useful, please cite it as:

```
@inproceedings{Deo2023,
  series = {HSMR2023},
  title = {Feasibility of Mobile Application for Surgical Robot Teleoperation},
  url = {http://dx.doi.org/10.31256/HSMR2023.63},
  DOI = {10.31256/hsmr2023.63},
  booktitle = {Proceedings of The 15th Hamlyn Symposium on Medical Robotics 2023},
  publisher = {The Hamlyn Centre,  Imperial College London London,  UK},
  author = {Deo,  Akhil and Kazanzides,  Peter},
  year = {2023},
  month = jun,
  collection = {HSMR2023}
}
```
