# Scientist

[Swift](https://swift.org) implementation inspired by [github/scientist](https://github.com/github/scientist)

## Usage

    func allow(user: User) {
	    var result = false
	    if let returnValue = Scienctist<Bool>().science({
	    	experiment in
	    	experiment.use {
	    		return module.check_user(user)
	    	}

	    	experiment.tryNew {
	    		return user.allowed
	    	}
	    }) {
	    	result = returnValue
	    }

	    return result
    }
