# Ubuntu 20.04 + CUDA 11.8 (devel: compilers, nvcc, headers included)
FROM nvidia/cuda:12.1.1-cudnn8-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-lc"]
ENV TZ=Asia/Tokyo

# --- Base tools (C++ build + Python + GUI apps) ---
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    ninja-build \
    git \
    pkg-config \
    gdb \
    ca-certificates \
    wget \
    curl \
    unzip \
    software-properties-common \
    sudo \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    # GUI / X11
    x11-apps \
    mesa-utils \
    libgl1-mesa-dri \
    libgl1-mesa-glx \
    libx11-6 \
    libxext6 \
    libxrender1 \
    libsm6 \
    libice6 \
    locales \
    # PNG viewer(s)
    eog \
    feh \
    libompl-dev ompl-demos \
    libgl1-mesa-dri libgl1-mesa-glx libglx-mesa0 mesa-utils \
    libxtst6 libxi6 \
    && rm -rf /var/lib/apt/lists/*

ENV ROS_DISTRO=humble
RUN locale-gen ja_JP ja_JP.UTF-8 \
    && update-locale LC_ALL=ja_JP.UTF-8 LANG=ja_JP.UTF-8
ENV LANG=ja_JP.UTF-8
RUN add-apt-repository universe \
    && curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null \
    && apt-get update && apt-get install -y \
        ros-$ROS_DISTRO-desktop \
        ros-dev-tools \
        ros-$ROS_DISTRO-xacro \
        ros-$ROS_DISTRO-joint-state-publisher \
        ros-$ROS_DISTRO-joint-state-publisher-gui \
        ros-$ROS_DISTRO-moveit \
        ros-$ROS_DISTRO-gazebo-ros-pkgs \
        ros-$ROS_DISTRO-gazebo-ros2-control \
        ros-$ROS_DISTRO-turtlebot3 \
        ros-$ROS_DISTRO-turtlebot3-msgs \
        ros-$ROS_DISTRO-turtlebot3-gazebo \
        python3-rosdep \
        python3-colcon-common-extensions \
        python3-colcon-mixin \
        python3-vcstool \
        python3-argcomplete \
        # for isaacsim bridge
        ros-$ROS_DISTRO-vision-msgs \
        ros-$ROS_DISTRO-ackermann-msgs \
        # ros-$ROS_DISTRO-realsense2-* \
        python3-rosinstall \
        python3-rosinstall-generator \
        python3-wstool \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && sudo rosdep init \
    && sudo rosdep update \
    && cd \
    && echo "export TURTLEBOT3_MODEL=waffle_pi" >> /etc/bash.bashrc \
    && echo "source /opt/ros/humble/setup.bash" >> /etc/bash.bashrc \
    && echo "source /usr/share/gazebo/setup.sh" >> /etc/bash.bashrc

RUN mkdir -p /root/.ignition/fuel \
    && cat > /root/.ignition/fuel/config.yaml <<'EOF'
servers: []
EOF

RUN mkdir -p /root/.gazebo \
    && cat > /root/.gazebo/gui.ini <<'EOF'
[geometry]
x=0
y=0
width=1200
height=800
EOF

# sun model
RUN mkdir -p /root/.gazebo/models/sun \
    && cat > /root/.gazebo/models/sun/model.config <<'EOF'
<?xml version="1.0"?>
<model>
  <name>sun</name>
  <version>1.0</version>
  <sdf version="1.6">model.sdf</sdf>
  <author>
    <name>local</name>
  </author>
  <description>Simple sun light model</description>
</model>
EOF
RUN cat > /root/.gazebo/models/sun/model.sdf <<'EOF'
<?xml version="1.0" ?>
<sdf version="1.6">
  <model name="sun">
    <static>true</static>
    <link name="link">
      <light name="sun_light" type="directional">
        <cast_shadows>true</cast_shadows>
        <pose>0 0 10 0 0 0</pose>
        <diffuse>0.8 0.8 0.8 1</diffuse>
        <specular>0.2 0.2 0.2 1</specular>
        <attenuation>
          <range>1000</range>
          <constant>0.9</constant>
          <linear>0.01</linear>
          <quadratic>0.001</quadratic>
        </attenuation>
        <direction>-0.5 0.1 -0.9</direction>
      </light>
    </link>
  </model>
</sdf>
EOF

# ground_plane model
RUN mkdir -p /root/.gazebo/models/ground_plane \
    && cat > /root/.gazebo/models/ground_plane/model.config <<'EOF'
<?xml version="1.0"?>
<model>
  <name>ground_plane</name>
  <version>1.0</version>
  <sdf version="1.6">model.sdf</sdf>
  <author>
    <name>local</name>
  </author>
  <description>Simple ground plane</description>
</model>
EOF
RUN cat > /root/.gazebo/models/ground_plane/model.sdf <<'EOF'
<?xml version="1.0" ?>
<sdf version="1.6">
  <model name="ground_plane">
    <static>true</static>
    <link name="link">
      <collision name="collision">
        <geometry>
          <plane>
            <normal>0 0 1</normal>
            <size>100 100</size>
          </plane>
        </geometry>
        <surface>
          <friction>
            <ode>
              <mu>100</mu>
              <mu2>50</mu2>
            </ode>
          </friction>
          <contact>
            <ode/>
          </contact>
        </surface>
      </collision>
      <visual name="visual">
        <cast_shadows>false</cast_shadows>
        <geometry>
          <plane>
            <normal>0 0 1</normal>
            <size>100 100</size>
          </plane>
        </geometry>
        <material>
          <ambient>0.8 0.8 0.8 1</ambient>
          <diffuse>0.8 0.8 0.8 1</diffuse>
          <specular>0.2 0.2 0.2 1</specular>
        </material>
      </visual>
    </link>
  </model>
</sdf>
EOF

ENV GAZEBO_MODEL_PATH=/root/.gazebo/models:${GAZEBO_MODEL_PATH}
ENV GAZEBO_RESOURCE_PATH=/root/.gazebo/models:${GAZEBO_RESOURCE_PATH}

RUN echo 'export GAZEBO_MODEL_PATH=/root/.gazebo/models:${GAZEBO_MODEL_PATH}' >> /etc/bash.bashrc \
    && echo 'export GAZEBO_RESOURCE_PATH=/root/.gazebo/models:${GAZEBO_RESOURCE_PATH}' >> /etc/bash.bashrc

# pip basics
RUN apt-get update && apt-get install -y python3-venv\
    && python3 -m venv /opt/venv\
    && source /opt/venv/bin/activate\
    && pip install -U pip setuptools wheel\
    && pip install torch==2.5.1 torchvision==0.20.1 torchaudio==2.5.1 --index-url https://download.pytorch.org/whl/cu121\
    && pip install pybullet

# (optional) Set up a workspace
WORKDIR /workspace

ENV PATH="/opt/venv/bin:$PATH"
# Default command
CMD ["/bin/bash"]
