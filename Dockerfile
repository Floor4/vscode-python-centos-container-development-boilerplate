ARG PYTHON_REQUIREMENTS_INSTALL_LOCATION="/local_installed_python_packages/"

FROM centos:8 AS dev_stage

ARG PYTHON_REQUIREMENTS_INSTALL_LOCATION

# Ensure we are building as root
USER root

RUN echo "root:root" | chpasswd

# Install the endpoint yum repo and update all available packages and install sudo
RUN yum -y update \
    && yum -y install sudo python38

ENV DEV_REQUIREMENTS_FILE_NAME=dev_yum_requirements.txt \
    PYTHON_REQUIREMENTS_FILE_NAME=requirements.txt \
    DEV_REQUIREMENTS_FILE_PATH=. \
    PYTHON_REQUIREMENTS_FILE_PATH=src

ADD ${DEV_REQUIREMENTS_FILE_PATH}/${DEV_REQUIREMENTS_FILE_NAME} .

# Install dev yum requirements
RUN yum -y install $(cat ${DEV_REQUIREMENTS_FILE_NAME})

ADD ${PYTHON_REQUIREMENTS_FILE_PATH}/${PYTHON_REQUIREMENTS_FILE_NAME} .

# Install python requirements
RUN mkdir -p "$PYTHON_REQUIREMENTS_INSTALL_LOCATION" \
&& pip3 install --ignore-installed --target=${PYTHON_REQUIREMENTS_INSTALL_LOCATION} -r ${PYTHON_REQUIREMENTS_FILE_NAME}

# Add requirements install location to path
ENV PYTHONPATH=${PYTHON_REQUIREMENTS_INSTALL_LOCATION}:$PYTHONPATH

ARG USERNAME=default

RUN useradd -m -s /bin/bash ${USERNAME} && echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/additional

RUN mkdir -p /home/${USERNAME}/.vscode-server/extensions/ \
    && chown -R ${USERNAME} /home/$USERNAME/.vscode-server/

USER ${USERNAME}

WORKDIR /home/${USERNAME}

CMD ["bash"]

FROM python:3.8.3-slim AS prod_stage

ARG PYTHON_REQUIREMENTS_INSTALL_LOCATION

# Copy installed requirements
COPY --from=dev_stage ${PYTHON_REQUIREMENTS_INSTALL_LOCATION} ${PYTHON_REQUIREMENTS_INSTALL_LOCATION}

# Add requirements to path
ENV PATH=${PYTHON_REQUIREMENTS_INSTALL_LOCATION}:$PATH

# Copy the code
COPY src /opt/src/

# Copy the README
ADD README.md /opt/

# Install the actual package
RUN pip install -e /opt/src/

ENTRYPOINT python
