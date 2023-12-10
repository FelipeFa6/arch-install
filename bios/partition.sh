#!/bin/bash

DISK="$1"

START_SECTOR=2048
TYPE_CODE=83

DISK_SIZE=$(lsblk -b --nodeps --output SIZE "$DISK")
PARTITION_SIZE=$((DISK_SIZE - START_SECTOR))

sfdisk --new-label "$DISK" "$START_SECTOR" "$PARTITION_SIZE" "$TYPE_CODE"


