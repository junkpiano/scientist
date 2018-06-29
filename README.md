# Scientist

*WIP*

A Swift library for carefully refactoring critical paths.

## Usage

    func allow(user: User) -> Bool {
	    if let returnValue = Scienctist<Bool>().science({
	    	experiment in
	    	experiment.use {
	    		return module.check_user(user)
	    	}

	    	experiment.tryNew {
	    		return user.allowed
	    	}
	    	experiment.run()
	    }) {
	    	return returnValue
	    }

	    return false
    }

## Porting from

- [github/scientist](https://github.com/github/scientist)
