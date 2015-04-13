# Registration page

## Typical Member Registration Flow (Signup Scenarios)

WP eMember was designed in a way so you (as the admin) have some customization freedom as to how the membership registration/signup flows on your membership site.

It is a good idea to read this post first and make up you mind on how you want your registration process to flow before you start setting eMember up.

If you are not sure about the difference between a “Join Us” page and a “Registration” page then read this post first.

1. Visitors land on your site.
1. Want to become a member after seeing some of the awesome content.
1. Follows the “Join Us” link.
1. The above mentioned link will take them to the “Membership Join Us” Page where you have explained all the different types of membership you offer. It may look similar to the one here.
1. From this page they can decide which membership option they want to choose (eg. Free, Silver, Gold or whatever you are offering)
1. If they choose the “Free Membership” then they just follow the link and sign up for a free membership. Remember, the free membership sign up is only possible if you (the admin) allow free membership on your site.
1. If they choose a “Paid Membership” then they make a payment by clicking on the payment button for the appropriate membership.
1. Once the Payment is confirmed (at this point the plugin knows what type of membership this member wants), the plugin will create the appropriate membership account for this visitor.
1. The member will receive an email that contains a “unique” link to complete the registration.
1. When the member clicks on that link in the email it will let them choose a “username” and “password” and complete the registration. At this point the member can log into the site.

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
confirm registration info
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
