require 'minitest'
require 'minitest/autorun'

require 'markdoc'

class SequenceTest < Minitest::Test
  def test_pic_output
    code = <<-CODE
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
CODE

    pic = <<-PIC
actor(Student,"Student");
object(P,"Partner Site");
object(App,"Web App");
object(Api,"Reg API");
step();

active(Student);
message(Student,P, "Choose course(S)");
active(P);
inactive(Student);
message(P,Api, "Issue key for(S)");
active(Api);
rmessage(Api,P, "Registration key(K)");
inactive(Api);
message(P,App, "Register with key(K)");
active(App);
inactive(P);
rmessage(App,Student, "Registration form");
active(Student);
message(Student,App, "Fill the form(F)");
inactive(Student);
message(App,App, "Save the form(F)");
message(App,Api, "Register(K, F)");
comment(Api,C,up 0.2 right, wid 0.9 ht 0.3 "New API");
active(Api);
inactive(App);
message(Api,Api, "Create course");
rmessage(Api,App, "Course details(C)");
active(App);
inactive(Api);
message(App,App, "Save(C)");
rmessage(App,Student, "Show course summary");
active(Student);
inactive(App);
message(Student,Api, "Click study button");
active(Api);
rmessage(Api,Student, "Show mypage");

step();
# Complete the lifelines
complete(Student);
complete(P);
complete(App);
complete(Api);
PIC
    assert(nil != Markdoc::Sequence.draw(code))
  end
end
