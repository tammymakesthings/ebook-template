#!/usr/bin/env python3 -w                      -*- Python; encoding: utf-8 -*-
##############################################################################
# log_count.py: Word count logging for markdown ebook projects
# SPDX-Copyright-Text: 2025, Tammy Cravit <tammy@tammymakesthings.com>
# SPDX-LicenseIdnetifier: MIT
##############################################################################

import argparse
import csv
import logging
import shutil
import sys
from datetime import datetime
from pathlib import Path
from tempfile import NamedTemporaryFile

#: The path to this script - used to find the wordcount.csv file
SCRIPT_PATH: Path = Path(__file__)

#: The project root directory
PROJECT_DIR: Path = SCRIPT_PATH.parent.parent

#: The default location of the word count log file
LOG_FILE: Path = PROJECT_DIR / "wordcount.csv"

#: THe field names for the log file
FIELDS = ["date", "count_chapters", "count_journals", "count_scenes"]

#: Today's timestamp
TODAY_TIMESTAMP = datetime.now().strftime("%Y-%m-%d")

#: True if more verbose output is desired.
VERBOSE: bool = False


def rewrite_existing_file(
    log_file_path: Path = LOG_FILE,
    field_list: list[str] = FIELDS,
    today_timestamp: str = TODAY_TIMESTAMP,
    chapter_count: int = 0,
    journal_count: int = 0,
    scene_count: int = 0,
) -> int:
    """
    Rewrite the existing log file, replacing today's entry with the new counts.
    """

    temp_output_file = NamedTemporaryFile(mode="w", delete=False)
    logging.debug("Creating temporary output file '%s'", temp_output_file.name)

    rows_written: int = 0
    with open(log_file_path.as_posix(), "r") as csv_file, temp_output_file:
        logging.debug("Reading log file '%s'", log_file_path.as_posix())

        reader = csv.DictReader(csv_file, fieldnames=field_list)
        writer = csv.DictWriter(temp_output_file, fieldnames=field_list)
        logging.debug(
            "Created CSV reader and writer objects for fields: %s", repr(field_list)
        )

        writer.writeheader()
        logging.debug("Wrote CSV header")

        for row in reader:
            if row["date"] == "date":
                logging.debug("Skipping row at index %d (today's date)", rows_written)
                continue
            if row["date"] != today_timestamp:
                logging.debug(
                    "Writing existing row at index %d for '%s'",
                    rows_written,
                    row["date"],
                )
                writer.writerow(row)
                rows_written = rows_written + 1
        logging.debug(
            "Writing record for today (date='%s'): chapters=%d, journals=%d, scenes=%d",
            today_timestamp,
            chapter_count,
            journal_count,
            scene_count,
        )

        writer.writerow(
            {
                "date": today_timestamp,
                "count_chapters": chapter_count,
                "count_journals": journal_count,
                "count_scenes": scene_count,
            }
        )
        rows_written = rows_written + 1

    logging.debug(
        "Moving temporary file: '%s' => '%s'",
        temp_output_file.name,
        log_file_path.as_posix(),
    )
    shutil.move(temp_output_file.name, log_file_path.as_posix())

    logging.debug("Done. Total rows processed=%d", rows_written)

    return rows_written


def create_new_file(
    log_file_path: Path,
    field_list: list[str] = FIELDS,
    today_timestamp: str = TODAY_TIMESTAMP,
    chapter_count: int = 0,
    journal_count: int = 0,
    scene_count: int = 0,
) -> None:
    """
    Create a new log file with today's counts.
    """

    with open(log_file_path.as_posix(), "w") as csv_file:
        logging.debug("Writing to '%s'", log_file_path.as_posix())
        writer = csv.DictWriter(csv_file, fieldnames=FIELDS)
        logging.debug("Created csv.DictWriter instance with fields: %s", repr(FIELDS))
        writer.writeheader()
        logging.debug("Wrote header row.")
        writer.writerow(
            {
                "date": today_timestamp,
                "count_chapters": chapter_count,
                "count_journals": journal_count,
                "count_scenes": scene_count,
            }
        )
        logging.debug(
            "Wrote data row: chapters=%d, journals=%d, scenes=%d",
            chapter_count,
            journal_count,
            scene_count,
        )
    logging.debug("Done.")


def update_log_file(
    log_file_path: Path = LOG_FILE,
    chapter_count: int = 0,
    journal_count: int = 0,
    scene_count: int = 0,
) -> bool:
    """
    Create or update the log file with today's information.
    """

    if log_file_path.exists():
        logging.info(
            "Recording counts for '%s' to '%s' (existing file)",
            TODAY_TIMESTAMP,
            log_file_path.as_posix(),
        )
        rewrite_existing_file(
            log_file_path=log_file_path,
            field_list=FIELDS,
            chapter_count=chapter_count,
            journal_count=journal_count,
            scene_count=scene_count,
        )
        return False
    else:
        logging.info(
            "Recording counts for '%s' to '%s' (new file)",
            TODAY_TIMESTAMP,
            log_file_path.as_posix(),
        )
        create_new_file(
            log_file_path=log_file_path,
            field_list=FIELDS,
            chapter_count=chapter_count,
            journal_count=journal_count,
            scene_count=scene_count,
        )
        return True


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        prog="LogCount",
        description="Update the word count log for the book",
        epilog="v1.00 / 2025-11-08 / Tammy Cravit <tammy@tammymakesthings.com>",
    )
    parser.add_argument(
        "chapters",
        nargs=1,
        metavar="WC_CHAPTERS",
        default=0,
        type=int,
        help="Number of words in chapter files",
    )
    parser.add_argument(
        "journals",
        nargs=1,
        metavar="WC_JOURNALS",
        default=0,
        type=int,
        help="Number of words in journal files",
    )
    parser.add_argument(
        "scenes",
        nargs=1,
        metavar="WC_SCENES",
        default=0,
        type=int,
        help="Number of words in scene files",
    )
    parser.add_argument(
        "-l",
        "--log-file",
        type=Path,
        default=LOG_FILE,
        help="log file to use to record the word counts",
    )
    parser.add_argument(
        "-v",
        "--verbose",
        action="store_true",
        help="enable more verbose output",
    )
    args = parser.parse_args()
    VERBOSE = args.verbose or False

    logging.basicConfig(level=(logging.DEBUG if VERBOSE else logging.INFO))
    logging.debug("Argument Parsing: Log file = '%s'", args.log_file.as_posix())
    logging.debug(
        "Argument Parsing: Counts = chapters=%d, journals=%d, scenes=%d",
        args.chapters[0],
        args.journals[0],
        args.scenes[0],
    )

    update_log_file(args.log_file, args.chapters[0], args.journals[0], args.scenes[0])
