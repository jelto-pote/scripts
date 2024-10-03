#!/bin/bash

# generic vars
LOG_CHECK_STRING="250 2.0.0 OK"
LOG_CHECK_DATE="$(date +"%b %d")"
LOGFILE="$HOME/.msmtp.log"

# Function to process files
process_files() {
    local FOLDER="$1"
    local PROCESSED_FOLDER="$2"
    local RECIPIENT="$3"
    local SUBJECT="$4"
    local BODY="$5"

    # Check for files in the folder, ignoring directories
    local FILES_CHECK=$(find "$FOLDER" -maxdepth 1 -type f)
        
    # If files are found, send them via email
    if [ -n "$FILES_CHECK" ]; then
        # Clear previous msmtp log to ensure fresh log entries
        > "$LOGFILE"
        
        # Use an array to store filenames
        mapfile -t files < <(find "$FOLDER" -maxdepth 1 -type f)

        # Send emails with individual files attached using mutt
        for file in "${files[@]}"; do
            echo "$BODY" | mutt -s "$SUBJECT" -a "$file" -- "$RECIPIENT"
        done
        

        # Wait for a brief moment to ensure the log is written
        sleep 3
        # Check the msmtp log to confirm the email was sent successfully
        if grep -q "$LOG_CHECK_STRING" "$LOGFILE"; then
            # If email was sent successfully, move the files to the 'processed' folder
            for file in "${files[@]}"; do
                mv "$file" "$PROCESSED_FOLDER"
                echo "Moved $file to $PROCESSED_FOLDER"
            done
            echo "All files sent and moved to $PROCESSED_FOLDER."
        else
            echo "Failed to send the email. Files will not be moved."
            echo "The log entry for today: $(grep "$LOG_CHECK_DATE" $HOME/.msmtp.log)"
        fi
    else
        echo "No files to send in $FOLDER."
    fi
}

# Purchase vars
BUY_FOLDER="$HOME/Sync/jelly/bookkeeping/2024/in/"
BUY_PROCESSED_FOLDER="${BUY_FOLDER}processed"
#BUY_RECIPIENT="x55i@aankoop.exactonline.be"
BUY_RECIPIENT="jp_id_serv@outlook.com"

BUY_SUBJECT="Automated File Submission: aankoopfacturen JP I&D Services"
BUY_BODY="Attached you find some purchase invoices. This email is automated. In case of any questions or bugs, don't hesitate to reach out. Have a nice day!"

# Sales vars
SELL_FOLDER="$HOME/Sync/jelly/bookkeeping/2024/out/"
SELL_PROCESSED_FOLDER="${SELL_FOLDER}processed"
#SELL_RECIPIENT="x55i@verkoop.exactonline.be"
SELL_RECIPIENT="jp_id_serv@outlook.com"
SELL_SUBJECT="Automated File Submission: verkoopfacturen JP I&D Services"
SELL_BODY="Attached you find some sales invoices. This email is automated. In case of any questions or bugs, don't hesitate to reach out. Have a nice day!"

# Run the function for both incoming and outgoing invoices
process_files "$BUY_FOLDER" "$BUY_PROCESSED_FOLDER" "$BUY_RECIPIENT" "$BUY_SUBJECT" "$BUY_BODY"
process_files "$SELL_FOLDER" "$SELL_PROCESSED_FOLDER" "$SELL_RECIPIENT" "$SELL_SUBJECT" "$SELL_BODY"
