API_URL="https://ai.kuch.workers.dev/api/v1/generate-commit"

edit=$([[ (! -z "${args[description]}") && (-z "${args[--edit]}") ]] && echo "" || echo "--edit")
force=$([[ ! -z "${args[--force]}" ]] && echo "--force" || echo "")

# Check if the description is empty
if [ -z "${args[description]}" ]; then
  echo "Error: The description is required."
  exit 1
fi

while true; do
  # Request the commit message
  json_data='{"description": "'${args[description]}'"}'
  response=$(curl -s -X POST -H "Content-Type: application/json" -d "$json_data" "$API_URL")

  # Parse the json response and get the commits array without using external tools
  commits=$(echo "$response" | sed -n 's/.*"commits":\[\(.*\)\].*/\1/p')

  # Convert the commits string to an array
  IFS='"' read -r -a commits <<<"$commits"

  # Filter the commits array to remove empty elements
  filtered_array=()
  for value in "${commits[@]}"; do
    if [ ${#value} -ge 10 ]; then
      filtered_array+=("$value")
    fi
  done

  # Show the commit messages options
  echo "Select a commit message:"
  echo ""
  echo "----------"
  echo ""
  for ((i = 0; i < ${#filtered_array[@]}; i += 1)); do
    echo "$((i + 1)). ${filtered_array[i]}" | awk '{gsub(/\\n\\n|\r\n\r\n/,"\n\n")}1'
    echo ""
    echo "----------"
    echo ""
  done

  echo "4. Generate more commit messages"
  echo ""
  echo "----------"
  echo ""

  # Ask the user to enter the number of the commit message
  read -p "Enter the number of the commit message (CTRL+C to exit): " commit_number

  # Chech if the number is valid (between 1 and 4)
  if [[ ! $commit_number =~ ^[1-4]$ ]]; then
    echo "Error: The number is invalid."
    exit 1
  fi

  # Verify if number is 4 to generate another commit message
  if [ $commit_number -eq 4 ]; then
    clear
    continue
  fi

  # Get the selected commit message should awk to remove the new lines
  selected_commit=$(echo "${filtered_array[$((commit_number - 1))]}" | awk '{gsub(/\\n\\n|\r\n\r\n/,"\n\n")}1')

  break
done

if [ ! -z ${args[--add-all]} ]; then
  git add --all
elif [ ! -z "${args[--add]}" ]; then
  git add ${args[--add]}
fi

git commit -m "$selected_commit" $edit

if [ ! -z ${args[--put]} ]; then
  git push $force origin $(git rev-parse --abbrev-ref HEAD)
fi
