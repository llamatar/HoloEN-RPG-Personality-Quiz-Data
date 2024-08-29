# holoEN_RPG_personality_quiz_data.py
# 
# This script generates the Choices and Guaranteed Results columns for the 
# SubcombinationsList tab of this spreadsheet (holoEN RPG Personality Quiz Data):
# https://docs.google.com/spreadsheets/d/1uCNcwZgxWc0I8WEW3X80SNoRGYCGAj2tdIIb2Xf3wbo/pubhtml
# 
# The Choices column contains subcombinations of quiz choices.
# The Guaranteed Results column contains the quiz result guaranteed by the subcombination if it exists.
# 
# A quiz choice is represented by a digit ranging from 1 to 4.
# A combination of choices is a string of 5 choices.
# A subcombination of choices is a combination of 5 choices or 0s representing any choice.
# A result is guaranteed if all branches of choices have the same result.
# 
# llamatar
# 2024-08-23

import csv
from typing import Dict, List, Optional

input_combinations_csv = 'LogHoloEnRpgPersonalityQuizCombinations.csv'
output_subcombinations_csv = 'holoEN_RPG_personality_quiz_data_subcombinations.csv'

quiz_choices_to_results = dict()


def main() -> None:
    # Reads quiz data from the input csv file 
    with open(input_combinations_csv, mode='r') as input_csv:
        reader = csv.DictReader(input_csv)
        for row in reader:
            quiz_choices_to_results[row['Choices']] = row['Result']

    subcombinations_to_guaranteed_result = get_subcombinations_to_guaranteed_result()

    # Writes all subcombinations and their corresponding guaranteed result to output csv file.
    with open(output_subcombinations_csv, mode='w', newline='') as output_csv:
        writer = csv.writer(output_csv)
        writer.writerow(['Choices', 'Guaranteed Result'])
        for k, v in subcombinations_to_guaranteed_result.items():
            writer.writerow([k, (v if v else '')])


def get_subcombinations_to_guaranteed_result() -> Dict[str, Optional[str]]:
    """Returns a dictionary of choice subcombination to its corresponding guaranteed result if it exists."""
    return { choice_subcombination : get_guaranteed_result(choice_subcombination) for choice_subcombination in get_all_choice_subcombinations() }


def get_all_choice_subcombinations() -> List[str]:
    """Returns a list of choice subcombinations filtered from all choice combinations."""
    return [choice_combination for choice_combination in get_all_choice_combinations() if '0' in choice_combination]


def get_all_choice_combinations() -> List[str]:
    """Returns a list of combinations of 5 digits ranging from 0 to 4."""
    return [change_base(n, 5).zfill(5) for n in range(5**5)]


def change_base(n: int, base: int) -> str:
    """Given a non-negative integer in base 10, returns a string representation in the given base between 2 and 16."""
    if not n >= 0:
        raise ValueError('n must be non-negative')
    if not 2 <= base <= 16:
        raise ValueError('base must be between 2 and 16')
    
    digits = '0123456789ABCDEF'
    if n < base:
        return digits[n]
    return change_base(n // base, base) + digits[n % base]


def get_guaranteed_result(choices: str) -> Optional[str]:
    """Returns the result guaranteed by the given choices if it exists.
    A result is guaranteed if all branches of choices have  the same result.
    If the given choices is non-branching (includes no zeros), the singular result is guaranteed.
    """
    choice_branches = generate_choice_branches(choices)
    results = get_results(choice_branches)
    return results[0] if all_same(results) else None


def generate_choice_branches(choices: str) -> List[str]:
    """Returns a list of all choices branching from the given quiz choices.
    Each '0' branches into '1', '2', '3', and '4'.
    For example, '41410' will generate '41441', '41442', '41443', and '41444'.
    If the given choices is non-branching (include no zeros), it will be the only element of the returned list. 
    """
    branches = ['']

    for choice in choices:
        if choice == '0':
            branches = double_list(double_list(branches))            
            for i in range(len(branches)):
                branches[i] += str(i % 4 + 1)
        else:
            for i in range(len(branches)):
                branches[i] += choice

    return branches


def double_list(items: list) -> list:
    """Returns a list with every item of the given list appearing twice."""
    output_list = []
    for item in items:
        output_list.append(item)
        output_list.append(item)
    return output_list


def get_results(choices_list: List[str]) -> List[str]:
    """Returns a list of results corresponding with the given list of quiz choices."""
    return [get_result(choices) for choices in choices_list]


def get_result(choices: str) -> str:
    """Returns the result of the given quiz choices."""
    return quiz_choices_to_results[choices]


def all_same(items: list) -> bool:
    """Returns whether all items in the given list are equal."""
    return all(item == items[0] for item in items)


if __name__ == '__main__':
    main()
