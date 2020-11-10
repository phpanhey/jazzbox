
int window_width = 800;
int window_height = 800;
char pressed_key;
// variables animation 1 
int step_a1 = 20;
int radius_a1 = 50;
int x_1 = 0;
int y_1 = 0;
int x_2 = 0;
int y_2 = 0;
int x_3 = 0;
int y_3 = 0;
int x_4 = 0;
int y_4 = 0;

boolean  was_at_edge_c1 = false;
boolean  was_at_edge_c2 = false;
boolean  was_at_edge_c3 = false;
boolean  was_at_edge_c4 = false;

//variables animation 2 
int step_a2 = 3;
int counter_a2 = 0;
int radius_a2 = 1100;
void setup() {
    x_1 = x_2 =x_3 = x_4 = window_width/2;
    y_1 = y_2 =y_3 = y_4 = window_height/2;
    size(800,800);
    background(253,235,83);
    noStroke();
    fill(255);
    frameRate(60);
}
//variables animation 5
float a = 0.0;
float s = 0.0;

//variables animation 6
float angle;
float jitter;

void draw() {
    background(0,0,0);
    switch(key) {
    case '1': 
        animation_1();
        break;
    case '2': 
        animation_2();
        break;
    case '3': 
        animation_3();
        break;
    case '4': 
        animation_4();
        break;
    case '5': 
        animation_5();
        break;
    default:
        animation_1();
        animation_3();
        animation_4();
        break;
    }
}

void animation_1() {
    ellipse(x_1,y_1, radius_a1,radius_a1);
    ellipse(x_2,y_2, radius_a1,radius_a1);
    ellipse(x_3,y_3, radius_a1,radius_a1);
    ellipse(x_4,y_4, radius_a1,radius_a1);
    
    if (was_at_edge_c1) {
        x_1+=step_a1;
        y_1+=step_a1;
        if (x_1>window_width/2) {
            was_at_edge_c1=false;
        }
    }else{
        x_1-=step_a1;
        y_1-=step_a1;    
        if (x_1<0) {
            was_at_edge_c1=true;
        }
    }
    
    if (was_at_edge_c2) {
        x_2-=step_a1;
        y_2+=step_a1;    
        if (x_2<window_width/2) {
            was_at_edge_c2=false;
        }
    }else{
        x_2+=step_a1;
        y_2-=step_a1;
        if (x_2>window_width) {
            was_at_edge_c2=true;
        }
    }

    if (was_at_edge_c3) {
        x_3+=step_a1;
        y_3-=step_a1;    
        if (x_3>window_width/2) {
            was_at_edge_c3=false;
        }
    }else{
        x_3-=step_a1;
        y_3+=step_a1;
        if (x_3<0) {
            was_at_edge_c3=true;
        }
    }

    if (was_at_edge_c4) {
        x_4-=step_a1;
        y_4-=step_a1;    
        if (x_4<window_width/2) {
            was_at_edge_c4=false;
        }
    }else{
        x_4+=step_a1;
        y_4+=step_a1;
        if (x_4>window_width) {
            was_at_edge_c4=true;
        }
    }
}

void animation_2(){
    if (radius_a2<0) {
        radius_a2=900;
    }
    radius_a2-=step_a2;
    counter_a2++;
    if (counter_a2 > step_a2) {
        counter_a2 = 0;
        int rand_num = (int) random(0,5);
        switch (rand_num) {
            case 0:
            fill(144, 252, 249);
            break;

            case 1:
            fill(98, 209, 205);
            break;

            case 2:
            fill(118, 211, 208);
            break;

            case 3:
            fill(71, 188, 184);
            break;

            case 4:
            fill(3, 84, 81);   
            break;
        }
    }
    ellipse(window_width/2,window_height/2, radius_a2,radius_a2);
}

//This is anmiation 2 just in greyscale
void animation_3(){
    if (radius_a2<0) {
        radius_a2=900;
    }
    radius_a2-=step_a2;
    counter_a2++;
    if (counter_a2 > step_a2) {
        counter_a2 = 0;
        int rand_num = (int) random(0,5);
        switch (rand_num) {
            case 0:
            fill(247, 247, 242);
            break;

            case 1:
            fill(229, 229, 195);
            break;

            case 2:
            fill(153, 153, 120);
            break;

            case 3:
            fill(38, 38, 33);
            break;

            case 4:
            fill(17, 17, 15);
            break;
        }
    }
    ellipse(window_width/2,window_height/2, radius_a2,radius_a2);
}

void animation_4(){
    animation_1();
    animation_2();
}

void animation_5(){
 rectMode(CENTER);
  a = a + 0.04;
  s = cos(a)*2;
  
  translate(width/2, height/2);
  scale(s); 
  fill(51);
  rect(0, 0, 50, 50); 
  
  translate(75, 0);
  fill(255);
  scale(s);
  rect(0, 0, 50, 50);       

}

void animation_6(){
  rectMode(CENTER);
  if (second() % 2 == 0) {  
    jitter = random(-0.1, 0.1);
  }
  angle = angle + jitter;
  float c = cos(angle);
  translate(width/2, height/2);
  rotate(c);
  rect(0, 0, 180, 180);   
}
