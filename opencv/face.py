import cv2
img = cv2.imread('/tmp/in.jpg')
gray = cv2.cvtColor(img,cv2.COLOR_BGR2GRAY)
 
faceCascade = cv2.CascadeClassifier('/root/jarvis/opencv/haarcascade_frontalface_alt.xml')
faces = faceCascade.detectMultiScale(gray, scaleFactor=1.1,minNeighbors=5, minSize=(30,30), flags=cv2.cv.CV_HAAR_SCALE_IMAGE)
 
for(x,y,w,h) in faces:
        cv2.rectangle(img, (x,y), (x+w, y+h), (255,0,0), 2)
 
cv2.imwrite('/tmp/out.jpg', img)
print len(faces)
