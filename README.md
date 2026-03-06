# tutorial_gazebo_ros2
## Git clone and build docker environment for gazebo humble
If you type the command below, you will enter the Docker container and be in the workspace directory.
```
git clone -b for_cpp https://github.com/tsuneka/tutorial_gazebo_ros2.git
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
新しいターミナルを開いて，Dockerコンテナに入ろう！
```
sudo docker compose exec -u root dev bash
mkdir -p /ros2_ws/src/
```
パッケージを作ろう．
```
ros2 pkg create my_first_ros 
# 余裕があれば，後で別のワークスペースで　ros2 pkg create my_first_ros --build-type ament_cmake --dependencies rclcpp std_msgs geometry_msgs　と打って，package.xmlを見てみよう，何かが違うはず．．．
# パッケージが作れたか確認しよう
ls　# my_first_ros ファイルがあれば問題なし！
cd my_first_ros/src/
# ほかの人が作ったソースコードをもらってみよう．
git clone https://github.com/tsuneka/my_first_ros.git
```
まず，CMakeLists.txtを下記の通りに編集しよう．

```
cmake_minimum_required(VERSION 3.8)
project(my_first_ros)

if(NOT CMAKE_CXX_STANDARD)
  set(CMAKE_CXX_STANDARD 17)
endif()

if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  add_compile_options(-Wall -Wextra -Wpedantic)
endif()

find_package(ament_cmake REQUIRED)
find_package(rclcpp REQUIRED)
find_package(std_msgs REQUIRED)
find_package(geometry_msgs REQUIRED)

add_executable(simple_talker src/my_first_ros/simple_talker.cpp)
ament_target_dependencies(simple_talker rclcpp std_msgs)

add_executable(simple_listener src/my_first_ros/simple_listener.cpp)
ament_target_dependencies(simple_listener rclcpp std_msgs)

add_executable(tb3_stop src/my_first_ros/tb3_stop.cpp)
ament_target_dependencies(tb3_stop rclcpp geometry_msgs)

add_executable(tb3_square_driver src/my_first_ros/tb3_square_driver.cpp)
ament_target_dependencies(tb3_square_driver rclcpp geometry_msgs)

install(TARGETS
  simple_talker
  simple_listener
  tb3_stop
  tb3_square_driver
  DESTINATION lib/${PROJECT_NAME}
)

ament_package()
```
次に，，CMakeLists.txtを下記の通りに編集しよう．
```
<?xml version="1.0"?>
<package format="3">
  <name>my_first_ros</name>
  <version>0.0.0</version>
  <description>TurtleBot3 C++ examples without msg and launch</description>
  <maintainer email="your_email@example.com">your_name</maintainer>
  <license>Apache-2.0</license>

  <buildtool_depend>ament_cmake</buildtool_depend>

  <depend>rclcpp</depend>
  <depend>std_msgs</depend>
  <depend>geometry_msgs</depend>

  <test_depend>ament_lint_auto</test_depend>
  <test_depend>ament_lint_common</test_depend>

  <export>
    <build_type>ament_cmake</build_type>
  </export>
</package>
```
ビルドしてみよう．
```
cd /workspace_host/ros2_ws
source /opt/ros/humble/setup.bash
colcon build --symlink-install
source install/setup.bash
```
実際にROS2の動作確認をしてみよう.

Terminal 1:
```
cd /workspace_host/ros2_ws
source /opt/ros/humble/setup.bash
source install/setup.bash
ros2 run my_first_ros simple_talker
```
Terminal 2:
```
cd /workspace_host/ros2_ws
source /opt/ros/humble/setup.bash
source install/setup.bash
ros2 run my_first_ros simple_listener
```
Terminal 3:
```
ros2 topic list
ros2 topic echo
```
Publish: "Hello ROS 2! count=0"　Receive: "Hello ROS 2! count=0" がディスプレイに出てくるか確認してね
## Create msg package
msgパッケージを作ろう
```
cd /workspace_host/ros2_ws/src/
ros2 pkg create my_first_ros_interfaces --build-type ament_cmake
# msgファイルの作成
mkdir msg
cd msg/
gedit RobotCommand.msg
```
float32 linear
float32 angular
```

```
package.xml に下記を追加
```
<buildtool_depend>ament_cmake</buildtool_depend>

<build_depend>rosidl_default_generators</build_depend>
<exec_depend>rosidl_default_runtime</exec_depend>

<member_of_group>rosidl_interface_packages</member_of_group>
```
CMakeLists.txt
```
cmake_minimum_required(VERSION 3.8)
project(my_first_ros_interfaces)

find_package(ament_cmake REQUIRED)
find_package(rosidl_default_generators REQUIRED)

rosidl_generate_interfaces(${PROJECT_NAME}
  "msg/RobotCommand.msg"
)

ament_export_dependencies(rosidl_default_runtime)

ament_package()
```
次にC++ノードのmy_first_ros側のpackage.xmlとCMakeLists.txtを編集しよう
```
# package.xml
<depend>my_first_ros_interfaces</depend>
# CMakeLists.txt
find_package(my_first_ros_interfaces REQUIRED)

ament_target_dependencies(tb3_square_driver
  rclcpp
  geometry_msgs
  my_first_ros_interfaces
)
```
## Create launch file
launchファイルを作ろう
```
cd /workspace_host/ros2_ws/src/
ros2 pkg create my_first_ros_bringup \
--build-type ament_python
mkdir launch
gedit gazebo_tb3.launch.py
```
from launch import LaunchDescription
from launch_ros.actions import Node
from launch.actions import ExecuteProcess

def generate_launch_description():

    gazebo = ExecuteProcess(
        cmd=['ros2','launch','turtlebot3_gazebo','turtlebot3_world.launch.py'],
        output='screen'
    )

    square_driver = Node(
        package='my_first_ros',
        executable='tb3_square_driver',
        output='screen'
    )

    return LaunchDescription([
        gazebo,
        square_driver
    ])
```
```
## Build & execute 
```
cd cd /workspace_host/ros2_ws/
colcon build --symlink-install
source install/setup.bash
ros2 launch my_first_ros_bringup gazebo_tb3.launch.py
```