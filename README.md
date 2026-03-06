# tutorial_gazebo_ros2
## Git clone and build docker environment for gazebo humble
If you type the command below, you will enter the Docker container and be in the workspace directory.
```
git clone https://github.com/tsuneka/tutorial_gazebo_ros2.git
cd tutorial_gazebo_ros2/
sudo docker compose build
sudo docker compose run dev
```
## Launch gazebo 
Launch gazebo with the following command:
```
source /opt/ros/humble/setup.bash
source /usr/share/gazebo/setup.sh
ros2 launch gazebo_ros gazebo.launch.py
```