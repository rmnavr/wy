    
    (import __future__ [annotations])
    
    ; TT proj
    
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1
    
    (import plotnine :as p9)
    (import plotnine [ggplot aes])
    
    (import sys)
    (. sys.stdout (reconfigure :encoding "utf-8"))
    
    (require hyrule [of as-> -> ->> doto case branch unless lif do_n list_n ncut])
    (import fptk *)
    (require fptk *)
    
; _____________________________________________________________________________/ }}}1
    
; utils ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1
    
; ■ [DC] Point2D, Vector2D ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2
    
    (defclass [dataclass] Point2D []
        ( #^ float x)
        ( #^ float y)
        (defn #^ Point2D __add__ [self other]
            (Point2D (+ self.x other.x) (+ self.y other.y))))
    
    (defclass [dataclass] Vector2D [Point2D]
        "synonim for Point2D class")
    
    (defn #^ (of Tuple float float)
        toXY
        [ #^ Point2D point]
        (return [point.x point.y]))
    
; ________________________________________________________________________/ }}}2
; ■ [F] Geom ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2
    
    (defn #^ Point2D
        rotateXY
        [ #^ Point2D pt
          #^ Point2D rot_center
          #^ float fi #_ rad]
        (setv [x y] (toXY pt))
        (setv [xC yC] (toXY rot_center))
        (setv x1 (py "xC + (x-xC)*cos(fi) - (y-yC)*sin(fi)"))
        (setv y1 (py "yC + (x-xC)*sin(fi) + (y-yC)*cos(fi)"))
        (Point2D x1 y1))
    
    (defn #^ float
        dotProduct
        [ #^ Vector2D v1
          #^ Vector2D v2]
        (setv [x1 y1] (toXY v1))
        (setv [x2 y2] (toXY v2))
        (py "x1*x2 + y1*y2"))
    
    (defn #^ float
        distPt2Pt
        [ #^ Point2D p1
          #^ Point2D p2]
        (setv [x1 y1] (toXY p1))
        (setv [x2 y2] (toXY p2))
        (py "sqrt((x2-x1)**2 + (y2-y1)**2)"))
    
    (defn #^ float
        distPt2Line
        [ #^ Point2D p
          #^ Point2D linePt1
          #^ Point2D linePt2]
        (setv [x0 y0] (toXY p))
        (setv [x1 y1] (toXY linePt1))
        (setv [x2 y2] (toXY linePt2))
        (py "abs((y2-y1)*x0 - (x2-x1)*y0 + x2*y1 - y2*x1)/distPt2Pt(linePt1, linePt2)"))
    
; ________________________________________________________________________/ }}}2
; ■ [F] physics ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2
    
    (defn #^ float
        revPerSec2radPerMs
        [ #^ float omega]
        (py "omega*2*math.pi/1000"))
    
; ________________________________________________________________________/ }}}2
    
; _____________________________________________________________________________/ }}}1
; Classes ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1
    
    (defclass [dataclass] GeomRect []
        ( #^ Point2D pCenter #_ mm)
        ( #^ float width #_ mm)
        ( #^ float length #_ mm)
        ( #^ float fi #_ "rad, dir x=0 is fi=0 degrees"))
    
    (defclass [dataclass] ZonedRect []
        ( #^ GeomRect rect)
        ( #^ float ballR #_ mm))
    
    (defclass [dataclass] Ball []
        ( #^ float x #_ mm)
        ( #^ float y #_ mm)
        ( #^ float fi #_ rad)
        ( #^ float vx #_ "m/s = mm/ms  | >0 is =>")
        ( #^ float vy #_ "m/s = mm/ms  | >0 is A")
        ( #^ float omega #_ "rad/ms       | >0 is V_o_A")
        (setv #^ float m 2.7 #_ gramm)
        (setv #^ float R 19. #_ mm)
        (setv #^ float Cf 0.47 #_ "drag kof")
        (setv #^ float Cm 0.92 #_ "magnus kof")
        (setv #^ float Cr (/ Cf 2 #_ "wind moment kof"))
        (setv #^ float J (py "2/5*m*(R**2)"))
        (setv #^ float S (py "math.pi*(R**2)")))
    
    (defclass ZoneN [Enum]
        "used both by Node and VisualNode"
        (setv Z0 "<0> Out of bounds")
        (setv Z1 "<1> Bottom Left")
        (setv Z2 "<2> Bottom Middle")
        (setv Z3 "<3> Bottom Right")
        (setv Z4 "<4> Center Left")
        (setv Z5 "<5> -not used-")
        (setv Z6 "<6> Center Right")
        (setv Z7 "<7> Top Left")
        (setv Z8 "<8> Top Middle")
        (setv Z9 "<9> Top Right"
        );
        (defn #^ str __str__ [self] f"{self.value}")
        (defn #^ str __repr__ [self] (self.__str__)))
    
    
    
    
; _____________________________________________________________________________/ }}}1
    
; [F] GeomRect ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1
    
    (defn #^ #(Point2D Point2D Point2D Point2D)
        calc4Pts
        [ #^ GeomRect rect]
        (setv x1_0 (py " rect.width /2")); \_right top
        (setv y1_0 (py " rect.length/2")); /
        (setv x2_0 (py "-rect.width /2")); \_left top
        (setv y2_0 (py " rect.length/2")); /
        (setv x3_0 (py "-rect.width /2")); \_left bottom
        (setv y3_0 (py "-rect.length/2")); /
        (setv x4_0 (py " rect.width /2")); \_right bottom
        (setv y4_0 (py "-rect.length/2"); /
        ); rotated around [0 0]:
        (setv pt1r (rotateXY (Point2D x1_0 y1_0) (Point2D 0 0) rect.fi))
        (setv pt2r (rotateXY (Point2D x2_0 y2_0) (Point2D 0 0) rect.fi))
        (setv pt3r (rotateXY (Point2D x3_0 y3_0) (Point2D 0 0) rect.fi))
        (setv pt4r (rotateXY (Point2D x4_0 y4_0) (Point2D 0 0) rect.fi)
        ); translate coords:
        (setv pts
            (lmap (partial plus rect.pCenter) [pt1r pt2r pt3r pt4r]))
        (return pts))
    
    (defn #^ bool
        isPointInsideRect
        [ #^ GeomRect rect
          #^ Point2D p
        ]; unpack:
        (setv [mx my] [p.x p.y])
        (setv [p1 p2 p3 p4unused] (calc4Pts rect)
        ); main:
        (setv [bx by] (toXY p1))
        (setv [ax ay] (toXY p2))
        (setv [dx dy] (toXY p3))
        (setv AM (Vector2D (- mx ax) (- my ay)))
        (setv AB (Vector2D (- bx ax) (- by ay)))
        (setv AD (Vector2D (- dx ax) (- dy ay)))
        (and (< 0 (dotProduct AM AB) (dotProduct AB AB))
              (< 0 (dotProduct AM AD) (dotProduct AD AD))))
    
    (defn #^ (of Tuple (of List float) (of List float)) #_ "[[x1 x2 ..] [y1 y2 ..]]"
        gRect2xyList
        [ #^ GeomRect grect
          #^ bool [looped_list False] #_ "if True, return list in order 1-2-4-3-1"]
        (setv xys
            (->> grect
                (calc4Pts)
                (lmap toXY))); will be of form [[x1 y1] [x2 y2] ..]
        (if (not looped_list)
            (return (lzip #* xys)); transpose
            (return (lzip #* (cut xys 0 4)))))
    
; _____________________________________________________________________________/ }}}1
; [F] ZonedRect ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1
    
    (defn #^ (of List GeomRect) #_ "there are 8 zones: 1 2 3 4 - 6 7 8 9"
        get8grects
        [ #^ ZonedRect zRect
        ]; unpacking:
        (setv W zRect.rect.width)
        (setv rL zRect.rect.length); name «rL» is temporary to not mess with WyTranspiler
        (setv fi zRect.rect.fi)
        (setv pC zRect.rect.pCenter)
        (setv R zRect.ballR
        ); main:
        (setv p1_0 (py "Point2D(-W/2-R/2, -rL/2-R/2)"))
        (setv p2_0 (py "Point2D( 0      , -rL/2-R/2)"))
        (setv p3_0 (py "Point2D( W/2+R/2, -rL/2-R/2)"))
        (setv p4_0 (py "Point2D(-W/4-R/2,  0       )"))
        (setv p6_0 (py "Point2D( W/4+R/2,  0       )"))
        (setv p7_0 (py "Point2D(-W/2-R/2,  rL/2+R/2)"))
        (setv p8_0 (py "Point2D( 0      ,  rL/2+R/2)"))
        (setv p9_0 (py "Point2D( W/2+R/2,  rL/2+R/2)"))
        (setv pts
            (->> [p1_0 p2_0 p3_0 p4_0 #_ 5 p6_0 p7_0 p8_0 p9_0]
                (lmap (partial plus pC))
                (lmap (partial rotateXY :rot_center pC :fi fi))))
        (setv [p1 p2 p3 p4 #_ 5 p6 p7 p8 p9] pts)
        (setv rect1 (GeomRect p1 R R fi))
        (setv rect2 (GeomRect p2 W R fi))
        (setv rect3 (GeomRect p3 R R fi))
        (setv rect4 (GeomRect p4 (py "R+W/2") rL fi))
        (setv rect6 (GeomRect p6 (py "R+W/2") rL fi))
        (setv rect7 (GeomRect p7 R R fi))
        (setv rect8 (GeomRect p8 W R fi))
        (setv rect9 (GeomRect p9 R R fi))
        (return [rect1 rect2 rect3 rect4 rect6 rect7 rect8 rect9]))
    
    (defn whatZoneIsPointIn
        [ #^ ZonedRect zRect #^ Point2D pt]
        (setv rects (get8grects zRect))
        (cond
            (isPointInsideRect (get rects 0) pt) ZoneN.Z1
            (isPointInsideRect (get rects 1) pt) ZoneN.Z2
            (isPointInsideRect (get rects 2) pt) ZoneN.Z3
            (isPointInsideRect (get rects 3) pt) ZoneN.Z4
            (isPointInsideRect (get rects 4) pt) ZoneN.Z6
            (isPointInsideRect (get rects 5) pt) ZoneN.Z7
            (isPointInsideRect (get rects 6) pt) ZoneN.Z8
            (isPointInsideRect (get rects 7) pt) ZoneN.Z9
            True ZoneN.Z0))
    
    (defn howDeepIsPointInZone
        [ #^ ZonedRect zRect
          #^ Point2D pt]
        (setv R zRect.ballR)
        (setv [zone1 zone2 zone3 zone4 #_ 5 zone6 zone7 zone8 zone9] (get8grects zRect))
        (case (whatZoneIsPointIn zRect pt)
            0 0
            1 (do (setv rL (distPt2Pt pt (get zones 0))) (if (> rL R) 0 (- R rL) ))
            2 (distPt2Line pt self.zone2.p3 self.zone2.p4)
            3 (do (setv rL (distPt2Pt p self.zone3.p2)) (if (> rL R) 0 (- R rL) ))
            4 (distPt2Line pt self.zone4.p2 self.zone4.p3)
            6 (distPt2Line pt self.zone6.p1 self.zone6.p4)
            7 (do (setv rL (distPt2Pt pt self.zone7.p4)) (if (> rL R) 0 (- R rL) ))
            8 (distPt2Line pt self.zone8.p1 self.zone8.p2)
            9 (do (setv rL (distPt2Pt pt self.zone9.p3)) (if (> rL R) 0 (- R rL) ))))
    
; _____________________________________________________________________________/ }}}1
; Main script ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1
    
    (setv gRect (GeomRect (Point2D 10 10) 2 5 (degrees 5)))
    (setv zRect (ZonedRect gRect 2))
    (setv test_point (Point2D 8 11))
    
    (->> (get8grects zRect)
          (lmap gRect2xyList)
          (setv xyss))
    
    (setv plot
        (+ (ggplot)
            #*
            (lfor &coords xyss
                (p9.geom_point
                    (aes :x (get &coords 0)
                        :y (get &coords 1))
                    :color "blue"))
            (p9.geom_point
                (aes :x test_point.x
                    :y test_point.y)
                :color "red")
            (p9.geom_point
                (aes :x 10
                    :y 10)
                :color "black")
            (p9.labs :title "zRect")
            (p9.scale_x_continuous :limits [-20 20])
            (p9.scale_y_continuous :limits [-20 20])
            (p9.coord_fixed :ratio 1)
            (p9.theme_minimal)))
    
    (plot.show)
    
    (print (whatZoneIsPointIn zRect test_point))
    
    
; _____________________________________________________________________________/ }}}1
     