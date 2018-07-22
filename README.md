# Scientist

[![Build Status](https://travis-ci.org/junkpiano/scientist.svg?branch=master)](https://travis-ci.org/junkpiano/scientist) [![Coverage Status](https://coveralls.io/repos/github/junkpiano/scientist/badge.svg?branch=master)](https://coveralls.io/github/junkpiano/scientist?branch=master)

A Swift library for carefully refactoring critical paths.

## Usage

    func allow(user: User) -> Bool {
	    return Scienctist<Bool>().science({
	    	experiment in
	    	experiment.use {
	    		return module.check_user(user)
	    	}

	    	experiment.tryNew {
	    		return user.allowed
	    	}
	    	experiment.run()
	    })!
    }

## Porting from

- [github/scientist](https://github.com/github/scientist)

## Author

- Yusuke "Steve" Ohashi <[github](https://github.com/junkpiano), [Twitter](https://twitter.com/junkpiano)>
