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
## Run the pub/sub example code
Open another terminal and create work space
```
sudo docker compose exec -u root dev bash
mkdir -p /ros2_ws/src/
```
Create a package
```
ros2 pkg create --build-type ament_python my_first_ros --dependencies rclpy std_msgs geometry_msgs
# Check if the package is ready
ls　# If you have the file my_first_ros, it's OK.
cd my_first_ros/
rm -r my_first_ros/
git clone https://github.com/tsuneka/my_first_ros.git
```
Edit setup.py in vscode.
Write it as follows:

```
from setuptools import setup

package_name = "my_first_ros"

setup(
    name=package_name,
    version="0.0.0",
    packages=[package_name],
    data_files=[
        ("share/ament_index/resource_index/packages", ["resource/" + package_name]),
        ("share/" + package_name, ["package.xml"]),
    ],
    install_requires=["setuptools"],
    zip_safe=True,
    maintainer="user",
    maintainer_email="user@example.com",
    description="Simple ROS 2 pub/sub and TurtleBot3 examples",
    license="Apache License 2.0",
    tests_require=["pytest"],
    entry_points={
        "console_scripts": [
            "simple_talker = my_first_ros.simple_talker:main",
            "simple_listener = my_first_ros.simple_listener:main",
            "tb3_square_driver = my_first_ros.tb3_square_driver:main",
            "tb3_stop = my_first_ros.tb3_stop:main",
        ],
    },
)
```
Let's build the package.
```
cd /workspace/ros2_ws
source /opt/ros/humble/setup.bash
colcon build --symlink-install
source install/setup.bash
```
Terminal 1:
```
cd /workspace/ros2_ws
source /opt/ros/humble/setup.bash
source install/setup.bash
ros2 run my_first_ros2_pkg simple_talker
```
Terminal 2:
```
cd /workspace/ros2_ws
source /opt/ros/humble/setup.bash
source install/setup.bash
ros2 run my_first_ros2_pkg simple_listener
```
Publish: "Hello ROS 2! count=0"　Receive: "Hello ROS 2! count=0" should be displayed in both terminals.