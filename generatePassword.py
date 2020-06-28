#!/user/bin/python3
'''
File: generatePassword.py

Description: This script generates a cryptographically secure password
    of the provided length.

    The generated password will be printed to stdout and occupy 
    exactly one line

    Example:
        > python3 generatePassword.py 20
        yZ3TOVYA9m2cIVyQdlUg
        >

Usage: 
    python3 generatePassword.py <passwordLength>

    This programm has one required argument:
        <passwordLength>:
            The length of the generated password

Author: miggoncan 

Date: 28-june-2020
'''
import os
import math
import sys

def generatePassword(passwordLength, betterPassword=False):
    '''Generate a password using a criptographically secure number 
        generator

    Keyword arguments:
    passwordLength: [int] Length of the generated password
    betterPassword: [bool] Determine whether to use special 
        characters in the password or not. Default is False

    return: [str] a random password
    '''
    OPTIONS = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
    EXTRA = '$%&_-.,:;<>*+/?!='
    
    password = ''

    if betterPassword:
        OPTIONS += EXTRA

    for i in range(passwordLength):
        # This call is computationally expensive, as it has to calculate 
        # numBitsNeeded and numBytesToGenerate each iteration
        index = randomInt(len(OPTIONS))
        password += OPTIONS[index]

    return password

def randomInt(max):
    '''Returns a cryptographically secure random int between 0 and max
        where max is not included
    '''
    numBitsNeeded = math.ceil( math.log(max) / math.log(2) )
    numBytesToGenerate = math.ceil( numBitsNeeded / 8)

    #Find numBytesToGenerate random bytes with a secure number generator
    randomBytes = os.urandom(numBytesToGenerate)
    #From bytes to an int, but it may contain more bits than needed
    randomIntWithExtraBits = int.from_bytes(randomBytes, byteorder='big')
    #If there are more bits generated than needed, delete them
    rInt = randomIntWithExtraBits >> (numBytesToGenerate * 8 - numBitsNeeded)

    #Make sure the number is smaller than the given max
    if rInt >= max:
        rInt = randomInt(max)

    return rInt;

def main():
    if len(sys.argv) !=  2:
        print(f'Usage: {sys.argv[0]} <passwordLength>',file=sys.stderr)
        sys.exit(1)
    passwordLength = int(sys.argv[1])
    print(generatePassword(passwordLength))

if __name__ == '__main__':
    main()