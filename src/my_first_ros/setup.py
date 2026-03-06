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