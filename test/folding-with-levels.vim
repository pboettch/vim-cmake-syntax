call system('rm ' .. output)
set foldmethod=syntax
%foldo!
TOhtml
exec 'w! ' .. output .. '-unfolded'
bdelete!
:8
foldc
TOhtml
exec 'w! ' .. output .. '-inner'
bdelete!
:7
foldc
TOhtml
exec 'w! ' .. output .. '-middle'
bdelete!
foldc
TOhtml
exec 'w! ' .. output .. '-outer'
bdelete!
:0
foldc
TOhtml
exec 'w! ' .. output .. '-all'
qa!
