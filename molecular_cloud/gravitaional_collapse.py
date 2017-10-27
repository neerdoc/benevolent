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

# Parse arguments
parser = argparse.ArgumentParser()
parser.add_argument("action", help="action to be performed by terraform, i.e.,\
 init/get/plan/apply/destroy")
args = parser.parse_args()


# Global variables
solar_system = {}
planet_tracks = []
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
    global planet_tracks
    for key, planet in solar_system['planets'].items():
        for moon in range(0, planet['count']):
            # Create a directory
            target_dir = data_dir + '/planets/' + key + '/{:02}'.format(moon)
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


# Execute terraform for all planned planets
def perform_terraforming(action):
    tf = Terraform()
    base_dir = getcwd()
    print('PWD = ')
    print(base_dir)
    for planet in planet_tracks:
        print('Terraforming ' + Fore.CYAN + planet + Fore.RESET)
        chdir(base_dir + '/' + planet)
        if action == 'destroy':
            choice = input(Fore.RED +
                           'Are you sure you want to destroy everything?!\n\
Anything other than "yes" will exit!')
            if choice != 'yes':
                print(Fore.RED + 'Ufa! That was close!')
                exit(0)
        check_terraform(getattr(tf, action)(
            '',
            no_color=IsNotFlagged,
            capture_output=False
        ))


# Main function. Keep it clean.
def main():
    get_solar_system()
    plan_collapse()
    perform_terraforming(args.action)


# Main body
if __name__ == '__main__':
    main()
