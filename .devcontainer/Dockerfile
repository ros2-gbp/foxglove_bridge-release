FROM ros:noetic-ros-core

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
  build-essential \
  clang \
  clang-format \
  curl \
  git \
  git-lfs \
  gnupg \
  lldb \
  lsb-release \
  openssh-client \
  python3-catkin-tools \
  python3-colcon-common-extensions \
  python3-pip \
  python3-rosdep \
  python3-rosinstall \
  python3-rosinstall-generator \
  python3-wstool \
  strace \
  && rm -rf /var/lib/apt/lists/*

ENV CC=clang
ENV CXX=clang++

# Authorize the ROS 2 GPG key and add the ROS 2 apt repository
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu focal main" > /etc/apt/sources.list.d/ros2.list

# Install ROS 2
RUN apt-get update && apt-get install -y --no-install-recommends \
  ros-galactic-foxglove-msgs \
  ros-galactic-ros-core \
  ros-galactic-rosbag2 \
  ros-galactic-rosbag2-storage-mcap \
  ros-galactic-tf2-msgs \
  && rm -rf /var/lib/apt/lists/*

# Create a ROS workspace
RUN mkdir -p /ros_ws/src/ros-foxglove-bridge

COPY package.xml /ros_ws/src/ros-foxglove-bridge/package.xml

# Initialize rosdep
RUN rosdep init && rosdep update

# Install rosdep dependencies for ROS 1
RUN . /opt/ros/noetic/setup.sh && \
    apt-get update && rosdep update && rosdep install -y \
      --from-paths /ros_ws/src \
      --ignore-src \
    && rm -rf /var/lib/apt/lists/*

# Install rosdep dependencies for ROS 2
RUN . /opt/ros/galactic/setup.sh && \
    apt-get update && rosdep update && rosdep install -y \
      --from-paths /ros_ws/src \
      --ignore-src \
    && rm -rf /var/lib/apt/lists/*

RUN catkin config --init --install \
  --workspace /ros_ws \
  --extend /opt/ros/noetic \
  --build-space build_ros1 \
  --devel-space devel_ros1 \
  --install-space install_ros1

SHELL ["/bin/bash", "-c"]

# Unset the ROS_DISTRO and add aliases to .bashrc
RUN echo $'\
unset ROS_DISTRO\n\
alias ros1_build_debug="catkin build -DCMAKE_BUILD_TYPE=Debug"\n\
alias ros1_build_release="catkin build -DCMAKE_BUILD_TYPE=RelWithDebInfo"\n\
alias ros1_foxglove_bridge="/ros_ws/install_ros1/env.sh roslaunch foxglove_bridge foxglove_bridge.launch --screen"\n\
alias ros2_build_debug="source /opt/ros/galactic/setup.bash && colcon build --event-handlers console_direct+ --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Debug"\n\
alias ros2_build_release="source /opt/ros/galactic/setup.bash && colcon build --event-handlers console_direct+ --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=RelWithDebInfo"\n\
alias ros2_foxglove_bridge="source /ros_ws/install/setup.bash && ros2 run foxglove_bridge foxglove_bridge --ros-args --log-level debug --log-level rcl:=INFO"\n\
' >> ~/.bashrc