# Python Base Image
FROM python:3.12.2-alpine3.19
LABEL maintainer="israelboluwatife17@gmail.com"

ENV PYTHONUNBUFFERED 1
ENV PYTHONDONTWRITEBYTECODE 1

# Copy the requirements.txt file from the local repo into the directory -> '/tmp/requirements.txt' of the base image.
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
# Create a directory named 'app' in the base image, and copy the app directory from the local repo into it.
COPY ./app /app
# Set the directory every other command should be run from in the base image to the 'app' directory.
WORKDIR /app
# Expose port 8000 from the image to our local machine.
EXPOSE 8000


ARG DEV=false
# Create a virtual environment
RUN python -m venv /py && \
# Upgrade pip in the virtual environment
    /py/bin/pip install --upgrade pip && \
# Install pacakage dependency for postgresql package
    apk add --update --no-cache postgresql-client && \
# Creates a virtual dependency package
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev && \
# Install the packages in the requirements.txt file
    /py/bin/pip install -r /tmp/requirements.txt && \
# If DEV argument is true, install the requirements.dev.txt packages
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
# Remove the tmp directory
    rm -rf /tmp && \
# Removes the virtual dependency packages
    apk del .tmp-build-deps && \
# Create a User named 'django-user', with password disabled, and doesn't create a home directory for the user.
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

# Updates the PATH variable. (Defines the directory where executables can be run) 
ENV PATH="/py/bin:$PATH"

# Switches to the user created (Changes from the root user.)
USER django-user