### tl;dr

[area's](https://github.com/jgv/area) `to_region` but with lazy loading and faster lookups

# Hello!
This gem converts area codes to states/regions.

```ruby
AreaCodeToState.new(929).call   # 'NY'
AreaCodeToState.new('321').call # 'FL'
AreaCodeToState.new(999).call   # nil
AreaCodeToState.new(800).call   # 'Toll Free'
AreaCodeToState.new(473).call   # 'Grenada'
x = AreaCodeToState.new('🥺')   # 🤔 hmm. so far so good
x.call                          # 😱 exception!
```
(Two-letter abbreviations are used whenever possible.)

This gem is functionally (actually?) the `to_region` method from the [area](https://github.com/jgv/area) gem (rewritten ✨) with a few minor differences:

* No zip code support
* Exceptions are slightly different (type/message/when they're thrown)

## Why?

I needed `to_region`'s functionality and I wanted it to load **as quickly as possible** with as few dependencies as possible.

How does this gem achieve that:

* Lazy loads the dataset (Example: If your rspec test doesn't use this class, the data files will never be read/processed.)
* Maps area codes to indices for faster lookups
* Fix gaps in the dataset
* Doesn't rely on any external libraries

On my computer this gem loads 99.8% - 99.9% faster than area gem (and lookups are typically faster —usually by more than 90%).

## Exceptions

**(When to Expect Them / How to Avoid Them)**

`AreaCodeToState.new(x)`will never throw an exception.

`AreaCodeToState.new(x).call` _will_ if `x` is not a valid area code.

That is, the area code passed into the initializer is not validated until `call`.

### You Hate Exceptions

You can do this instead:
```ruby
if AreaCodeToState.valid_area_code?(x)
  puts AreaCodeToState.area_code_to_region(x)
end
```

If you are going to go that route, note: **strings are never valid area codes for _this_ class method** (`area_code_to_region`). (Whereas `#call` _does_ accept strings.)

```ruby
AreaCodeToState.area_code_to_region('800')       # Exception!
                AreaCodeToState.new('800').call  # 'Toll Free'
```

_However_, `AreaCodeToState.valid_area_code?` returns the integer form of an area code.

So you can do:
```ruby
valid_area_code = AreaCodeToState.valid_area_code?(x)
if valid_area_code
  puts AreaCodeToState.area_code_to_region(valid_area_code)
end
```

## Monkey Patching

This gem doesn't monkey patch like [area](https://github.com/jgv/area/tree/master/lib/area) (No judgement —just wanted this gem to be as lightweight as possible).

If you want this gem to be a drop-in replacement for `area`:
```ruby
class Integer
  def to_region
    AreaCodeToState.new(self).call
  end
end
```
