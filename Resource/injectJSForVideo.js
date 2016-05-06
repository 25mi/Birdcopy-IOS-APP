var vs=document.body.getElementsByTagName("video"),tempId;
for(var i=0;i<vs.length;i++)
{
    tempId=vs[i].id;
    if(!tempId)continue;
    eval("var v"+i+"=document.getElementById('"+tempId+"');");
    eval("v"+i+".addEventListener('play',function(){this.pause();window.webkit.messageHandlers.playvideo.postMessage(this.src);});");
}