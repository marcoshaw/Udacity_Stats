#v1.0
#Also works with the style changes made early in January 2014.
#Issue: If user changes their display name, the posts will get split up, for example:
#/users/169623515/marco-shaw (changed to this after 1 or 2 weeks after registration)
#/users/169623515/marco-226 (old)
#
#Need to look for duplicate IDs ("169623515"), and combine their data.

$ie=new-object -com internetexplorer.application
#$ie.visible=$true
$ie.navigate("http://forums.udacity.com/tags/ud617/?sort=active&page=1#ud617")
while ($ie.busy) {sleep -milliseconds 50}
#$ie.document.body.innerhtml.tostring()
#[regex]::matches($ie.document.body.innerhtml.tostring(),'http://forums.udacity.com/users/\d+/(\w+-\w+|\w+)')|foreach{$_.groups[1]}|select -exp value|group|sort -desc count|ft -a count,name
$users=@{}

#$ie.document.body.innerhtml.tostring()

$pages=@("1")

[regex]::matches($ie.document.body.innerhtml.tostring(),'/tags/ud617/\?sort=active&amp;page=([0-9]+)#ud617">[0-9]+')|foreach{$_.groups[1]}|select -exp value|sort|foreach{$pages+=$_}

#[regex]::matches($ie.document.body.innerhtml.tostring(),'/tags/ud617/\?sort=active&amp;page=[0-9]+" >')

#|foreach{$_.groups[0]}|select -exp value|sort|foreach{$_}
#/tags/ud617/?sort=active&amp;page=2" >2

$pages|foreach{

$ie.navigate("http://forums.udacity.com/tags/ud617/?sort=active&page=${_}#ud617")
while ($ie.busy) {sleep -milliseconds 50}

#[regex]::matches($ie.document.body.innerhtml.tostring(),'/questions/\d+/[a-z-]+#ud617')|foreach{$_.groups}|select -exp value|foreach -begin {$i=0} -process {
[regex]::matches($ie.document.body.innerhtml.tostring(),'/questions/\d+/[a-z-]+#ud617')|foreach{$_.groups}|select -exp value|foreach {
  #"http://forums.udacity.com" + $_
  $ie.navigate("http://forums.udacity.com" + $_)
  while ($ie.busy) {sleep -milliseconds 50}
  [regex]::matches($ie.document.body.innerhtml.tostring(),'/users/\d+/([a-z0-9-]+)')|foreach{$_.groups[0]}|select -exp value|sort|foreach{if($users[$_]){$users[$_]+=1}else{$users[$_]=1}}
  #set-variable -name question$i -value ([regex]::matches($ie.document.body.innerhtml.tostring(),'/users/\d+/([a-z0-9-]+)')|foreach{$_.groups[1]}|select -exp value|sort)
  #$i++
}

}

$users_with_karma=@()

$users.GetEnumerator()|foreach{
  #$_.keys
  $ie.navigate("http://forums.udacity.com" + $_.name)
  #"http://forums.udacity.com" + $_.keys
  while ($ie.busy) {sleep -milliseconds 50}
  $karma_score=[regex]::matches($ie.document.body.innerhtml.tostring(),'<div class="scoreNumber" id="user-reputation">([0-9,]+)</div>')|foreach{$_.groups[1]}|select -exp value
  $obj=new-object psobject
  $obj|add-member "user" $_.name
  $obj|add-member "posts" ([int]$_.value)
  $obj|add-member "karma" ([int]$karma_score)
  $users_with_karma+=$obj
}



# karma
#[regex]::matches($ie.document.body.innerhtml.tostring(),'<div class="scoreNumber" id="user-reputation">([0-9]+)</div>')

#$users=@{}

#get-variable question?|foreach{$_.value}|foreach{if($users[$_]){$users[$_]+=1}else{$users[$_]=1}}

#get-variable question??|foreach{$_.value}|foreach{if($users[$_]){$users[$_]+=1}else{$users[$_]=1}}