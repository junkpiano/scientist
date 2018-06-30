# Scientist

*WIP*

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
