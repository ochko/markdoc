# Registration page

## Typical Member Registration Flow

Here is how it will work.

1. User visits our registration page
1. User enters email address
1. If it is new user
  1. Fills in registration form
  1. Submits the form
  1. If there is validation error
    1. Fix the validation error
    1. Review the fix
    1. Submit again
  1. If there is no error
    1. Submit the form
1. If it is returning user
  1. Enter password
  1. If the entered password is wrong
    1. Ask password again
  1. If password is correct
    1. Good to go, proceed next step
  1. Confirm account info
1. Confirm registration info

<p class="page-break"><!-- break --></p>

## Flows

```pseudo
visit registration page
enter email address
if new user
  fill in registration form
  submit
  if validation error
    fix registration form
    review the fix
    submit
  else
    submit
  end
else
  enter password
  if password wrong
    ask password again
  else
    good to go
  end
  confirm account info
end
✓ confirm registration info
```

<p class="page-break"><!-- break --></p>

## Sequence

```sequence
Student = Actor
P = Partner Site
App = Web App
Api = Reg API

Student -> P : Choose course(S)
P -> Api : Issue key for(S)
P <~ Api : Registration key(K)
P -> App : Register with key(K)
Student <~ App : Registration form
Student -> App : Fill the form(F)
App : Save the form(F)
App -> Api : Register(K, F) # New API
Api : Create course
App <~ Api : Course details(C)
App : Save(C)
Student <~ App : Show course summary
Student -> Api : Click study button
Student <~ Api : Show mypage
```

## Example

```ruby
def block_code(code, language)
  case language
  when 'pseudo', 'pseudocode'
    wrap_svg Pseudocode.draw(code)
  when 'seq', 'sequence'
    wrap_svg Sequence.draw(code)
  else
    Pygments.highlight(code, lexer: language)
  end
end
```
