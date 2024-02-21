#!/bin/bash

# General topics applicable to both roles
general_topics=("Communication" "Experience" "Problem Solving" "Git" "HTTP" "OOP" "Architecture")

# Role-specific topics
front_end_topics=("HTML" "CSS" "JavaScript" "Angular" "React")
back_end_topics=("NodeJS" "Java" "SQL")

# Create associative arrays to hold scores and descriptions
declare -A scores
declare -A descriptions

# Variables for statistics
totalScore=0
countScores=0
highestScore=0
lowestScore=10
highestTopic=""
lowestTopic=""

echo "Interview Feedback Entry📝"

# Ask for candidate's name
read -p "Enter candidate's name: " name

# Select role
echo "Select the role for the interview:"
echo "1. Front-end"
echo "2. Back-end"
read -p "Enter choice (1 or 2): " role_choice

# Determine topics based on role choice
topics=("${general_topics[@]}") # Start with general topics
if [ "$role_choice" == "1" ]; then
    topics+=("${front_end_topics[@]}")
    role="Front-end"
elif [ "$role_choice" == "2" ]; then
    topics+=("${back_end_topics[@]}")
    role="Back-end"
else
    echo "Invalid selection. Exiting."
    exit 1
fi

# Loop through topics to get scores and optional descriptions
for topic in "${topics[@]}"; do
    echo "Topic: $topic"
    read -p "Rate from 1 to 10 (press Enter if not applicable): " score
    if [[ -n $score ]]; then
        scores[$topic]=$score
        read -p "Add a brief description (press Enter to skip): " description
        descriptions[$topic]="$description"

        # Update statistics
        ((totalScore+=score))
        ((countScores++))
        if [[ $score -gt $highestScore ]]; then
            highestScore=$score
            highestTopic=$topic
        fi
        if [[ $score -lt $lowestScore ]]; then
            lowestScore=$score
            lowestTopic=$topic
        fi
    fi
done

# Save to a Markdown file
feedback_file="feedback_${name}_${role}.md"
echo "# Feedback for $name ($role Role) 🌟" > "$feedback_file"
echo "" >> "$feedback_file" # Add a blank line

# Add topics, scores, and descriptions
for topic in "${topics[@]}"; do
    if [[ -n ${scores[$topic]} ]]; then
        # Add emoji based on score
        score_emoji="😐"
        if (( ${scores[$topic]} > 7 )); then
            score_emoji="😄"
        elif (( ${scores[$topic]} < 4 )); then
            score_emoji="😟"
        fi
        echo "## $topic" >> "$feedback_file"
        echo "Score: **${scores[$topic]}** $score_emoji" >> "$feedback_file"
        if [[ -n ${descriptions[$topic]} ]]; then
            echo "Description: ${descriptions[$topic]}" >> "$feedback_file"
        fi
        echo "" >> "$feedback_file" # Add a blank line for spacing
    fi
done

# Add summary statistics
if [ $countScores -gt 0 ]; then
    averageScore=$(echo "scale=2; $totalScore / $countScores" | bc -l)
else
    averageScore="N/A"
    highestScore="N/A"
    lowestScore="N/A"
    highestTopic="N/A"
    lowestTopic="N/A"
fi

echo "## Summary Statistics 📊" >> "$feedback_file"
echo "- Average Score: **$averageScore**" >> "$feedback_file"
echo "- Highest Score: **$highestScore** on **$highestTopic**" >> "$feedback_file"
echo "- Lowest Score: **$lowestScore** on **$lowestTopic**" >> "$feedback_file"
echo "" >> "$feedback_file"

# Add Generative AI prompt
echo "Given the following scores and descriptions for a technical interview:" >> "$feedback_file"
for topic in "${topics[@]}"; do
    if [[ -n ${scores[$topic]} ]]; then
        description=${descriptions[$topic]:-"No description provided."}
        echo "- $topic with the score of ${scores[$topic]} and the description: '$description'" >> "$feedback_file"
    fi
done
echo "" >> "$feedback_file"
echo "Generate a feedback summary highlighting strong points, weak points, and other observations and recommendations." >> "$feedback_file"

echo "Feedback saved to $feedback_file"
