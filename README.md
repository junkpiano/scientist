# Scientist

*WIP*

[Swift](https://swift.org) of [github/scientist](https://github.com/github/scientist)

## Usage

    func allow(user: User) -> Bool {
	    var result = false
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
	    	result = returnValue
	    }

	    return result
    }

## Inspired By

- [github/scientist](https://github.com/github/scientist)