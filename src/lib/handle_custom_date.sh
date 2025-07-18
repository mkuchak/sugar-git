#!/usr/bin/env bash

# [@bashly-upgrade lib handle_custom_date]
handle_custom_date() {
  local date_flag="${args[--date]}"
  local time_flag="${args[--time]}"
  
  # Check if only one flag is provided
  if [[ (-n "$date_flag" && -z "$time_flag") || (-z "$date_flag" && -n "$time_flag") ]]; then
    echo "Error: Both --date and --time flags must be used together."
    echo "Usage: --date YYYY-MM-DD --time HH:MM:SS"
    exit 1
  fi
  
  # If neither flag is provided, return normally
  if [[ -z "$date_flag" && -z "$time_flag" ]]; then
    return 0
  fi
  
  # Validate date format (YYYY-MM-DD)
  if [[ ! "$date_flag" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    echo "Error: Invalid date format. Expected format: YYYY-MM-DD"
    echo "Example: --date 2025-07-02"
    exit 1
  fi
  
  # Validate time format (HH:MM:SS)
  if [[ ! "$time_flag" =~ ^[0-9]{2}:[0-9]{2}:[0-9]{2}$ ]]; then
    echo "Error: Invalid time format. Expected format: HH:MM:SS"
    echo "Example: --time 20:20:18"
    exit 1
  fi
  
  # Validate date values
  local year month day
  IFS='-' read -r year month day <<< "$date_flag"
  
  if [[ $month -lt 1 || $month -gt 12 ]]; then
    echo "Error: Invalid month. Month must be between 01-12"
    exit 1
  fi
  
  if [[ $day -lt 1 || $day -gt 31 ]]; then
    echo "Error: Invalid day. Day must be between 01-31"
    exit 1
  fi
  
  # Validate time values
  local hour minute second
  IFS=':' read -r hour minute second <<< "$time_flag"
  
  if [[ $hour -lt 0 || $hour -gt 23 ]]; then
    echo "Error: Invalid hour. Hour must be between 00-23"
    exit 1
  fi
  
  if [[ $minute -lt 0 || $minute -gt 59 ]]; then
    echo "Error: Invalid minute. Minute must be between 00-59"
    exit 1
  fi
  
  if [[ $second -lt 0 || $second -gt 59 ]]; then
    echo "Error: Invalid second. Second must be between 00-59"
    exit 1
  fi
  
  # Create the full datetime string in ISO 8601 format
  local datetime="${date_flag}T${time_flag}"
  
  # Set environment variables for git
  export GIT_COMMITTER_DATE="$datetime"
  export GIT_AUTHOR_DATE="$datetime"
  
  return 0
} 