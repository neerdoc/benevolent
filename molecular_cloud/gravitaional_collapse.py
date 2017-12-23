#!/usr/bin/env python3
"""
Module documentation.
"""

# Imports
import yaml
from colorama import Fore
from os import makedirs, path, listdir, chdir, getcwd
from shutil import copyfile
from python_terraform import Terraform, IsNotFlagged
import argparse
from time import sleep

# Parse arguments
parser = argparse.ArgumentParser()
parser.add_argument("action", help="action to be performed by terraform, i.e.,\
 init/get/plan/apply/destroy")
parser.add_argument("-na", "--noauto",
                    help="prevent automatic run of init before apply",
                    action="store_true")
parser.add_argument("-r", "--roll_delay",
                    type=int,
                    help="run commands in rolling with delay in between them\
 the delay is set in minutes")

args = parser.parse_args()


# Global variables
solar_system = {}
planet_tracks = []
destroy_tracks = []
data_dir = 'data'


def recursive_overwrite(src, dest, ignore=None):
    if path.isdir(src):
        if not path.isdir(dest):
            makedirs(dest)
        files = listdir(src)
        if ignore is not None:
            ignored = ignore(src, files)
        else:
            ignored = set()
        for f in files:
            if f not in ignored:
                recursive_overwrite(path.join(src, f),
                                    path.join(dest, f),
                                    ignore)
    else:
        copyfile(src, dest)


# Read the settings file.
def get_solar_system():
    global solar_system
    with open('solar_system.yml', 'r') as stream:
        try:
            solar_system = yaml.load(stream)
        except yaml.YAMLError as exc:
            print(exc)


# Create all the planets with correct variables.
def plan_collapse():
    global planet_tracks, destroy_tracks
    base_dir = getcwd()
    for key, planet in solar_system['planets'].items():
        for moon in range(0, planet['count']):
            # Check for condition first
            if 'condition' in planet:
                condition = planet['condition']
                # Try replacing all variables in the condition
                for agency, orbit in solar_system['sun'].items():
                    if 'default' in orbit:
                        condition = condition.replace('{' + agency + '}',
                                                      str(orbit['default']))
                print(Fore.MAGENTA + "Condition found! base_dir =  " +
                      base_dir + Fore.RESET)
                if path.isfile(base_dir + '/' + condition):
                    print(Fore.MAGENTA + "Condition found! Skipping " +
                          Fore.CYAN + key + Fore.MAGENTA + "." + Fore.RESET)
                    break
            # Create a directory
            target_dir = data_dir + '/planets/' + key + '/{:02}'.format(moon)
            if 'temporary' in planet:
                destroy_tracks.append(target_dir)
            planet_tracks.append(target_dir)
            # Copy the files to it
            src_dir = 'protoplanets/' + key
            recursive_overwrite(src_dir, target_dir)
            # Create the variables FileExistsError
            with open(target_dir + '/variables.tf', 'w') as out:
                for sputnik in planet['variables']:
                    out.write('variable "' + sputnik + '" {\n')
                    for agency, orbit in solar_system['sun'][sputnik].items():
                        if agency == 'auto':
                            out.write('  ' +
                                      'default = "{:02}"\n'.format(moon))
                        elif agency == 'single':
                            out.write('  default = "' +
                                      orbit[moon % len(orbit)] + '"\n')
                        elif type(orbit) == str:
                            out.write('  ' + agency + ' = "' + orbit + '"\n')
                        elif type(orbit) == list:
                            out.write('  ' + agency + ' = [')
                            for item in orbit:
                                out.write('"' + item + '" ,')
                            out.write(']\n')
                        elif type(orbit) == int:
                            out.write('  ' +
                                      agency + ' = "' +
                                      str(orbit) + '"\n')
                        else:
                            print(Fore.RED + 'Oops. Do not now what this is.')
                            exit(2)
                    out.write('}\n')


# Check calls to Terraform
def check_terraform(data):
    code = data[0]
    if code == 1:
        print(Fore.RED + 'Terraform failed. Please fix before trying again!')
        exit(1)
    elif code == 2:
        return True
    return False


# Perform terraforming
def execute_terraform(base_dir, planet, action, tf):
    print('Terraforming ' + Fore.CYAN + planet + Fore.RESET)
    chdir(base_dir + '/' + planet)
    check_terraform(getattr(tf, action)(
        '',
        no_color=IsNotFlagged,
        capture_output=False
    ))


# Countdown function
def check_for_sleep(roll):
    print("")
    if roll:
        for count_down in range(roll * 60, 0, -1):
            print("\r" + Fore.MAGENTA + str(count_down) + Fore.RESET +
                  " seconds to go.", end='')
            sleep(1)
        print("\r" + Fore.MAGENTA + "0" + Fore.RESET +
              " seconds to go.")


# Execute terraform for all planned planets
def perform_terraforming(action, auto=False, roll=0):
    tf = Terraform()
    base_dir = getcwd()
    if action == 'destroy':
        choice = input(Fore.RED +
                       'Are you sure you want to destroy everything?!\n\
Anything other than "yes" will exit!')
        if choice != 'yes':
            print(Fore.RED + 'Ufa! That was close!' + Fore.RESET)
            exit(0)
        print(Fore.RESET)
        for planet in reversed(planet_tracks):
            execute_terraform(base_dir=base_dir,
                              planet=planet,
                              action=action,
                              tf=tf)
    elif action == 'apply' and auto:
        for planet in planet_tracks:
            execute_terraform(base_dir=base_dir,
                              planet=planet,
                              action='init',
                              tf=tf)
            execute_terraform(base_dir=base_dir,
                              planet=planet,
                              action=action,
                              tf=tf)
            check_for_sleep(roll)
        # Now check destroy_tracks
        for planet in destroy_tracks:
            execute_terraform(base_dir=base_dir,
                              planet=planet,
                              action='destroy',
                              tf=tf)
            check_for_sleep(roll)
    else:
        for planet in planet_tracks:
            execute_terraform(base_dir=base_dir,
                              planet=planet,
                              action=action,
                              tf=tf)
            check_for_sleep(roll)
        # Now check destroy_tracks
        for planet in destroy_tracks:
            execute_terraform(base_dir=base_dir,
                              planet=planet,
                              action='destroy',
                              tf=tf)
            check_for_sleep(roll)


# Main function. Keep it clean.
def main():
    get_solar_system()
    plan_collapse()
    print(args)
    perform_terraforming(args.action, not args.noauto, args.roll_delay)


# Main body
if __name__ == '__main__':
    main()
