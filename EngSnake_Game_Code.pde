import processing.serial.*;

final int sizeRect = 15;
final int speed = sizeRect;
PFont f;
Serial port;
Point bonusPoint = new Point();
Point headPoint = new Point();
Point[] snake = new Point[200];
Point[] lastPositions = new Point[201];
int count = 0;
int deathTime;
String input = "stay";
boolean bonusDrawn = false;
boolean updated = false;
boolean died = false;

public class Point
{
  public int x = -500;
  public int y = -500;
  public int xMoving = 0;
  public int yMoving = 0;
}

void findSerialPort()
{
  String[] listPorts = Serial.list();
  for (int i = 0; i < listPorts.length; i++)
  {
    try
    {
      if (!listPorts[i].contains("cu.usbmodem"))
      {
        println(listPorts[i]);
        port = new Serial(this, listPorts[i], 9600);
        if (port.available() > 0)
        {
          if (port.readStringUntil('.').equals("OFF."))
          {
            break;
          }
        }
      }
    }
    catch(RuntimeException e)
    {
      
    }
  }
}

void setBonus()
{
  int bonusTime = millis()/1000;
  if ((bonusTime + 1) % 5 == 0 && !bonusDrawn)
  {
    int X = int(random(0,width));
    int Y = int(random(0,height));
    bonusPoint.x = sizeRect - (X%sizeRect)+X;
    bonusPoint.y = sizeRect - (Y%sizeRect)+Y;
    bonusDrawn = true;
  }
  else if ((bonusTime + 1) % 5 != 0)
  {
    bonusDrawn = false;
  }
}

void addPart()
{
  Point newPart = new Point();
  newPart.x = -500;
  newPart.y = -500;
  snake[count] = newPart;
}

void checkBonus()
{
  if (bonusPoint.x == headPoint.x && bonusPoint.y == headPoint.y)
  {
    bonusPoint.x = -500;
    bonusPoint.y = -500;
    addPart();
    count++;
  }
}


void saveLastPositions()
{
  Point tempPos = new Point();
  tempPos.x = headPoint.x;
  tempPos.y = headPoint.y;
  for (int i = count-1; i >=1 ;i--)
  {
    lastPositions[i] = lastPositions[i-1];
  }
  Point tempPosIndex0 = new Point();
  tempPosIndex0.x = headPoint.x;
  tempPosIndex0.y = headPoint.y;
  lastPositions[0] = tempPosIndex0;
}

void moveSnake()
{
  for (int i = 0; i < count; i++)
  {
    snake[i].x = lastPositions[i].x;
    snake[i].y = lastPositions[i].y;
  }
}

void moveHead(int x, int y)
{
  headPoint.xMoving = speed*x;
  headPoint.yMoving = speed*y;
}
void translation(String read)
{
  if (read.equals("up.") && headPoint.yMoving == 0)
  {
    moveHead(0,1);
  }
  else if (read.equals("down.") && headPoint.yMoving == 0)
  {
    moveHead(0,-1);
  }
  else if (read.equals("right.") && headPoint.xMoving == 0)
  {
    moveHead(1,0);
  }
  else if (read.equals("left.") && headPoint.xMoving == 0)
  {
    moveHead(-1,0);
  }
  else if (read.equals("stay"))
  {
    if (headPoint.xMoving != 0)
    {
      headPoint.x = headPoint.x + headPoint.xMoving;
    }
    else if (headPoint.yMoving != 0)
    {
      headPoint.y = headPoint.y + headPoint.yMoving;
    }
    if (headPoint.x < 0 || headPoint.x > width || headPoint.y < 0 || headPoint.y > height)
    {
      died();
    }
  }
}

void checkIfHeadTouchTail()
{
  for (int i = 2; i < count; i++)
  {
    if (headPoint.x == snake[i].x && headPoint.y == snake[i].y)
    {
      died();
    }
  }
}

void update(String read)
{ 
  if (read!="stay")
  {
    println(read);
    input = read;
  }
  int time = millis()/100;
  if (time % 2 == 0 && !updated)
  {
    updated = true;
    checkBonus();
    saveLastPositions();
    translation(input);
    moveSnake();
    checkIfHeadTouchTail();
    input = "stay";
  }
  else if (time % 2 != 0)
  {
    updated = false;
  }
}

void paint()
{
  fill(124);
  rect(headPoint.x, headPoint.y, sizeRect,sizeRect);
  fill(0);
  for (int i = 0; i < count; i++)
  {
    rect(snake[i].x, snake[i].y, sizeRect, sizeRect);
  }
}

void died()
{
  died = true;
  port.clear();
  port.write(1);
  deathTime = millis()/1000;
}

void setup()
{
  size(300, 300);
  f = createFont("Arial", 10, true);
  findSerialPort();
  port.write(1);
  rect(250,250,sizeRect,sizeRect);
  headPoint.x = 0;
  headPoint.y = 0;
  headPoint.xMoving = speed;
  headPoint.yMoving = 0;
}

void draw()
{
  if (died)
  {
    background(0);
    textFont(f,25);
    String[] text = {"GAME OVER\nScore =", str(count)};
    fill(255);
    textAlign(CENTER);
    text(join(text,' '), width/2, height/2);
    if (millis()/1000 - deathTime == 3)
    {
      exit();
    }
  }
  else
  {
    background(255);
    setBonus();
    try
    {
      rect(bonusPoint.x, bonusPoint.y, sizeRect, sizeRect);
    }
    catch(RuntimeException e)
    {
      println("wait");
    }
    String readingString = "stay";
    if (port.available() > 0)
    {
      try
      {
        readingString = port.readStringUntil('.');
      }
      catch(RuntimeException e)
      { 
        println(e);
      }
    }
    update(readingString);
    paint();
  }
}