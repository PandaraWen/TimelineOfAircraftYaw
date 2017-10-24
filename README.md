# TimelineOfAircraftYaw
This demo is created to describe an issue of `DJITimelineMission`.

![image](./_readme_resource/main.jpg)

## Install
The demo relys on [DJIDemoKit](https://github.com/PandaraWen/DJIDemoKit), a handy framework to build DJI-device-releated demo. So you have to run `pod install` before build this demo project.

## Detail
### 0x01
Option **Go yaw with angular velocity** would let you specify an angular velocity, then schedules **8** `TimelineElement` of `DJIAircraftYawAction` with `relativeAngle` of **45** degrees, and `angularVelocity` of your specified angular velocity. Finally try start that timeline.

### 0x02


