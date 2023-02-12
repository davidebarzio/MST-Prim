;;;; -*- Mode: Lisp -*-

;;;; mst.lisp
;;;; Davide Barzio 844556
;;;; Federico Benaglia 845138

(defparameter *vertices* (make-hash-table :test #'equal)) 

(defparameter *arcs* (make-hash-table :test #'equal))

(defparameter *graphs* (make-hash-table :test #'equal))

(defparameter *visited* (make-hash-table :test #'equal))

(defparameter *vertex-keys* (make-hash-table :test #'equal))

(defparameter *previous* (make-hash-table :test #'equal))

(defparameter *heaps* (make-hash-table :test #'equal))

(defparameter *positions* (make-hash-table :test #'equal)) 



(defun is-graph (graph-id)
  (gethash graph-id *graphs*))


(defun new-graph (graph-id)
  (or (gethash graph-id *graphs*)
      (if (not (null graph-id))
          (setf (gethash graph-id *graphs*) graph-id))))


(defun delete-graph (graph-id)
  (if (is-graph graph-id)
      (progn
        (remhash graph-id *graphs*)

        (maphash #'(lambda (key val)
                     (if (eql (second key) graph-id)
                         (remhash key *arcs*))) 
                 *arcs*)

        (maphash #'(lambda (key val)
                     (if (eql (second key) graph-id)
                         (remhash key *vertices*)))
                 *vertices*))))


(defun new-vertex (graph-id vertex-id)  
  (if (and (or (symbolp vertex-id)
               (integerp vertex-id))
           (not (null vertex-id))
           (is-graph graph-id))

      (or (gethash  (list 'vertex graph-id vertex-id) *vertices*)
          (setf (gethash (list 'vertex graph-id vertex-id) *vertices*)
                (list 'vertex graph-id vertex-id)))))


(defun graph-vertices (graph-id) 
  (if (is-graph graph-id)      
      (let ((vertex-rep-list '()))
        (maphash #'(lambda (key val)
                     (if (eql (second key) graph-id)
                         (push key vertex-rep-list)))  
                 *vertices*) 
        vertex-rep-list)))


(defun new-arc (graph-id vertex-id1 vertex-id2 &optional (weight 1))
  (if (and (is-graph graph-id)
           (gethash  (list 'vertex graph-id vertex-id1) *vertices*) 
           (gethash  (list 'vertex graph-id vertex-id2) *vertices*)                
           (not (eql vertex-id1 vertex-id2))
           (> weight 0))
      (progn
        (maphash #'(lambda (key val)
                     (if (or (and (eql (second key) graph-id)
                                  (eql (third key) vertex-id1)
                                  (eql (fourth key) vertex-id2)
                                  (not (eql (fifth key) weight)))
                             (and (eql (second key) graph-id)
                                  (eql (third key) vertex-id2)
                                  (eql (fourth key) vertex-id1)
                                  (not (eql (fifth key) weight))))
                         (remhash key *arcs*)))
                 *arcs*)
        
        (setf (gethash (list 'arc graph-id vertex-id2 vertex-id1 weight)
                       *arcs*)
              (list 'arc graph-id vertex-id2 vertex-id1 weight))

        (setf (gethash (list 'arc graph-id vertex-id1 vertex-id2 weight)
                       *arcs*) 
              (list 'arc graph-id vertex-id1 vertex-id2 weight)))))


(defun graph-arcs (graph-id)
  (if (is-graph graph-id)      
      (let ((arc-rep-list '()))
        (maphash #'(lambda (key val)
                     (if (eql (second key) graph-id)
                         (push key arc-rep-list)))   
                 *arcs*)
        arc-rep-list)))  


(defun graph-vertex-neighbors (graph-id vertex-id)
  (if (and (is-graph graph-id)
           (gethash (list 'vertex graph-id vertex-id) *vertices*))
      (let ((arc-rep-list '()))
        (maphash #'(lambda (key val)
                     (if (and (eql (second key) graph-id)
                              (eql (third key) vertex-id))
                         (push key arc-rep-list))) 
                 *arcs*)
        arc-rep-list))) 


(defun graph-vertex-adjacent (graph-id vertex-id)
  (if (and (is-graph graph-id)
           (gethash (list 'vertex graph-id vertex-id) *vertices*))
      (let ((vertex-rep-list '()))
        (maphash #'(lambda (key val)
                     (if (and (eql (second key) graph-id)
                              (eql (third key) vertex-id))
                         (push (gethash (list 'vertex graph-id (fourth key))
                                        *vertices*)
                               vertex-rep-list)))
                 *arcs*)
        vertex-rep-list))) 


(defun graph-print (graph-id)
  (if (is-graph graph-id)
      (format t "~%Vertici:~%~S~2%Archi:~%~S"
              (graph-vertices graph-id)
              (graph-arcs graph-id))))


(defun new-heap (heap-id &optional (capacity 42))
  (if (not (null heap-id))
      (or (gethash heap-id *heaps*)
          (setf (gethash heap-id *heaps*)
                (list 'heap heap-id 0 (make-array capacity :adjustable t))))))


(defun heap-id (heap-rep)
  (second heap-rep))


(defun heap-size (heap-rep)
  (third heap-rep))


(defun heap-actual-heap (heap-rep)
  (fourth heap-rep))


(defun heap-delete (heap-id)
  (maphash #'(lambda (key val)
               (if (eql (first key) heap-id)
                   (remhash key *positions*)))
           *positions*)
  (remhash heap-id *heaps*)
  t)


(defun heap-empty (heap-id)
  (eql (heap-size (gethash heap-id *heaps*)) 0))


(defun heap-not-empty (heap-id)
  (and (gethash heap-id *heaps*)
       (> (heap-size (gethash heap-id *heaps*)) 0)))


(defun heap-head (heap-id)
  (if (heap-not-empty heap-id)
      (aref (heap-actual-heap (gethash heap-id *heaps*)) 1)))


(defun is-heap (heap-id)
  (gethash heap-id *heaps*))


(defun heap-insert (heap-id K V)
  (let ((val (gethash heap-id *heaps*)))
    (if (and (= (- (array-total-size (heap-actual-heap val)) 1)
                (heap-size val))
             (is-heap heap-id))
        
        (adjust-array (heap-actual-heap val)
                      (+ (array-total-size (heap-actual-heap val)) 
                         (floor (/ (array-total-size (heap-actual-heap val))
                                   2)))))
    
    (setf (third val) (+ 1 (heap-size val)))
    (setf (aref (heap-actual-heap val) (heap-size val))
          (list K V))
    (setf (gethash (list heap-id (list K V)) *positions*)
          (heap-size val)) 
    (heap-property-check heap-id (heap-size val))))

 
(defun heap-property-check (heap-id pos)
  (let ((val (gethash heap-id *heaps*)))  
    (if (is-heap heap-id)
        (if (and (> pos 1)
                 (< (first (aref (fourth val) pos))
                    (first (aref (fourth val) (floor pos 2)))))

            (progn (let ((switch (aref (fourth val) pos)))
                     (setf (aref (fourth val) pos)
                           (aref (fourth val) (floor pos 2)))
                     (setf (aref (fourth val) (floor pos 2))
                           switch)
                     (setf (gethash (list heap-id (aref (fourth val) pos))
                                    *positions*)
                           pos)
                     (setf (gethash (list heap-id (aref (fourth val)
                                                        (floor pos 2)))
                                    *positions*)
                           (floor pos 2)))
              (heap-property-check heap-id (floor pos 2)))

          (or (and (> pos 1)
                   (>=  (first (aref (fourth val) pos))
                        (first (aref (fourth val) (floor pos 2)))))
              (= pos 1))))))


(defun heap-extract (heap-id)
  (if (and (is-heap heap-id)
           (>= (heap-size (is-heap heap-id)) 1))
      (let ((val (gethash heap-id *heaps*))
            (element-extracted ()))           
        (push (second (heap-head heap-id)) element-extracted)
        (push (first (heap-head heap-id)) element-extracted) 
        (remhash (list heap-id (aref (heap-actual-heap val) 1))
                 *positions*)  
        (setf (aref (heap-actual-heap val) 1)
              (aref (heap-actual-heap val) (heap-size val)))
        (if (> (heap-size val) 1) 
            (setf (gethash (list heap-id (aref (heap-actual-heap val) 1))
                           *positions*)  1))    
        (setf (aref (heap-actual-heap val) (heap-size val)) nil)
        (decf (third val))
        (if (>= (array-total-size (heap-actual-heap val))
                (* 2 (heap-size val)))
            (adjust-array (heap-actual-heap val) 
                          (- (array-total-size (heap-actual-heap val))
                             (floor (/ (array-total-size
                                        (heap-actual-heap val)) 4)))))
        (heapify heap-id 1)
        element-extracted)))

    
(defun heapify (heap-id p)
  (if (is-heap heap-id)
      (let ((son-list (find-sons heap-id p))
            (heap (heap-actual-heap (gethash heap-id *heaps*))))
        (cond ((= (list-length son-list) 2)
               
               (cond ((and (<= (first (first son-list))
                               (first (second son-list)))
                           (< (first (first son-list))
                              (first (aref heap p))))
                      (let ((father (aref heap p)))
                        (setf (aref heap p) (aref heap (* 2 p)))
                        (setf (aref heap (* 2 p)) father)
                        (setf (gethash (list heap-id (aref heap p))
                                       *positions*) p) 
                        (setf (gethash (list heap-id (aref heap (* 2 p)))
                                       *positions*) (* 2 p)))
                      (heapify heap-id (* 2 p)))
                     
                     ((and (> (first (first son-list))
                              (first (second son-list)))
                           (< (first (second son-list))
                              (first (aref heap p))))
                      (let ((father (aref heap p)))
                        (setf (aref heap p) (aref heap (+ 1 (* 2 p))))
                        (setf (aref heap (+ 1 (* 2 p))) father)
                        (setf (gethash (list heap-id (aref heap p))
                                       *positions*) p) 
                        (setf (gethash (list heap-id
                                             (aref heap (+ 1 (* 2 p))))
                                       *positions*) (+ 1 (* 2 p))))
                      (heapify heap-id (+ 1 (* 2 p))))
                     
                     (t (and (<=  (first (aref heap p))
                                  (first (first son-list)))
                             (<=  (first (aref heap p))
                                  (first (second son-list)))))))
              
              ((= (list-length son-list) 1)               
               (cond ((< (first (first son-list))
                         (first (aref heap p)))
                      (let ((father (aref heap p)))
                        (setf (aref heap p) (aref heap (* 2 p)))
                        (setf (aref heap (* 2 p)) father)
                        (setf (gethash (list heap-id (aref heap p))
                                       *positions*) p) 
                        (setf (gethash (list heap-id (aref heap (* 2 p)))
                                       *positions*) (* 2 p)))
                      (heapify heap-id (* 2 p)))
                     
                     (t (>= (first (first son-list))
                            (first (aref heap p))))))
              
              (t (eql (list-length son-list) 0)))))) 


(defun find-sons (heap-id p)
  (let ((sons '())
        (heap (heap-actual-heap (gethash heap-id *heaps*))))
    (if (and (gethash heap-id *heaps*)
             (< (* 2 p) (array-total-size heap)))
        (cond ((and (< (+ 1 (* 2 p)) (array-total-size heap))
                    (not (eql (aref heap (* 2 p)) nil))
                    (not (eql (aref heap (+ 1 (* 2 p))) nil)))
               (push (aref heap (+ 1 (* 2 p))) sons)
               (push (aref heap (* 2 p)) sons))

              ((and (not (eql (aref heap (* 2 p)) nil))
                    (eql (aref heap (+ 1 (* 2 p))) nil))
               (push (aref heap (* 2 p)) sons))))
    sons))


(defun heap-modify-key (heap-id new-key old-key V) 
  (if (is-heap heap-id)
      (let ((newkey (list heap-id (list new-key V)))
            (oldkey (list heap-id (list old-key V))))
        (if (not (eql (gethash oldkey *positions*) nil))
            (progn
              (setf (aref (fourth (gethash heap-id *heaps*))
                          (gethash oldkey *positions*)) (list new-key V))
              (setf (gethash newkey *positions*)
                    (gethash oldkey *positions*))
              (remhash oldkey *positions*) 
              (heapify heap-id (gethash newkey *positions*))
              (heap-property-check heap-id
                                   (gethash newkey *positions*)))))))


(defun heap-print (heap-id) 
  (if (is-heap heap-id) 
      (progn
        (format t "Heap: ~S~%Heap-size: ~S~%Array: ~S"
                heap-id (heap-size (gethash heap-id *heaps*))
                (heap-actual-heap (gethash heap-id *heaps*)))
        t)))
  

(defun mst-vertex-key (graph-id vertex-id)
  (gethash (list graph-id vertex-id) *vertex-keys*))


(defun mst-previous (graph-id V)
  (gethash (list graph-id V) *previous*))


(defun mst-prim (graph-id source)
  (if (and (is-graph graph-id)
           (gethash (list 'vertex graph-id source) *vertices*))
      (progn
        (new-heap graph-id)
        (build-heap graph-id source)
        (decrease-queue graph-id)
        (maphash #'(lambda (key val)
                     (remhash key *visited*))
                 *visited*))))


(defun build-heap (graph-id source)
  (maphash #'(lambda (key val)
               (let ((couple (list (second key) (third key))))
                 (if (eql (second key) graph-id)
                     (cond ((eql (third key) source)
                            (setf (gethash couple *vertex-keys*) 0)
                            (setf (gethash couple *previous*) 0)
                            (heap-insert graph-id 0 (third key)))
                           
                           (t (setf (gethash couple *vertex-keys*)
                                    most-positive-double-float)
                              (setf (gethash couple *previous*) 0)
                              (heap-insert graph-id most-positive-double-float
                                           (third key)))))))
           *vertices*))


(defun decrease-queue (heap-id)
  (if (heap-not-empty heap-id)
      (let ((head-vertex (second (heap-head heap-id)))
            (extracted (second (heap-extract heap-id))))    
        (setf (gethash (list 'visited heap-id head-vertex) *visited*)
              head-vertex)
        (check-adjs heap-id (graph-vertex-neighbors heap-id extracted))
        (decrease-queue heap-id))))


(defun check-adjs (heap-id lista)
  (let ((key (list heap-id (fourth (car lista)))))
    (if (not (null lista))
        (if (gethash (list 'visited heap-id (fourth (car lista)))
                     *visited*)
            (check-adjs heap-id (cdr lista))
          (if (< (fifth (car lista)) (gethash key *vertex-keys*))
              (progn              
                (setf (gethash key *previous*) (third (car lista)))
                (heap-modify-key heap-id (fifth (car lista))
                                 (gethash key *vertex-keys*)
                                 (fourth (car lista))) 
                (setf (gethash key *vertex-keys*) (fifth (car lista)))
                (check-adjs heap-id (cdr lista)))
            (check-adjs heap-id (cdr lista)))))))


(defun mst-get (graph-id source)
  (if (eql (mst-previous graph-id source) 0)
      (progn
        (maphash #'(lambda (key val)
                     (if (and (eql graph-id (first key))
                              (eql val 0))
                         (progn
                           (remhash key *previous*)
                           (remhash key *vertex-keys*))))
                 *previous*)
        (list-insert graph-id source (lista-figli-previous graph-id source)))))


(defun list-insert (graph-id father l)
  (if (null l)
      nil
    (let ((temp (gethash (list graph-id (first l)) *vertex-keys*)))
      (remhash (list graph-id (first l)) *vertex-keys*)
      (cons (gethash (list 'arc graph-id father (first l) temp)
                     *arcs*)   
            (append (list-insert graph-id
                                 (first l)
                                 (lista-figli-previous graph-id (first l)))
                    (list-insert graph-id father (cdr l)))))))


(defun lista-figli-previous (graph-id source)
  (let ((list '()))
    (maphash #'(lambda (key val)
                 (if (and (eql (first key) graph-id)
                          (eql val source))
                     (progn
                       (push (list (second key)
                                   (gethash key *vertex-keys*)) list)
                       (remhash key *previous*))))
             *previous*) 
    (transform-list (sort list 'sort-doppio)))) 


(defun transform-list (l)
  (if (null l)
      nil
    (cons (first (first l)) (transform-list (cdr l)))))


(defun sort-doppio (x y) 
  (cond ((number< x y) t)
        ((number< y x) nil)
        (t (vertex< x y))))


(defun number< (term1 term2)
  (< (second-term term1)
     (second-term term2)))


(defun vertex< (term1 term2)
  (cond ((and (symbolp (first-term term1))
              (symbolp (first-term term2)))
         (string< (first-term term1)
                  (first-term term2)))
        
        ((and (numberp (first-term term1))
              (numberp (first-term term2)))
         (< (first-term term1)
            (first-term term2)))
        
        ((or (and (numberp (first-term term1))
                  (symbolp (first-term term2)))
             (and (numberp (first-term term2))
                  (symbolp (first-term term1))))
         (mixed (first-term term1)
                (first-term term2)))))


(defun mixed (term1 term2)
  (numberp term1))     


(defun first-term (term)
  (first term))


(defun second-term (term)
  (second term))


;;;; end of file -- mst.lisp --

