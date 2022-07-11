FROM python:3.3-alpine

EXPOSE 23

RUN apk add --no-cache bash

# Create a group and user
RUN addgroup -S dbadmin && adduser -S dbadmin -G dbadmin

# Tell docker that all future commands should run as the appuser user
USER dbadmin