;;; mtorus-state.el --- state functions of the mtorus
;; $Id$
;; Copyright (C) 2004 by Stefan Kamphausen
;;           (C) 2004 by Sebastian Freundt
;; Author: Stefan Kamphausen <mail@skamphausen.de>
;;         Sebastian Freundt <hroptatyr@users.berlios.de>
;; Created: 2004/07/31
;; Keywords: bookmarks, navigation, tools, extensions, user

;; This file is not (yet) part of XEmacs.

;; This program is free software; you can redistribute it and/or modify it
;; under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING. If not, write to the Free
;; Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
;; 02111-1307, USA.


;;; Commentary:
;; This file holds useful code to
;; - dump the complete torus to a file
;; - read a complete torus from a file

;; *** ToDo:


;;; History


;;; Code:

(require 'mtorus-utils)
(require 'mtorus-convert)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Administrative Settings ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defgroup mtorus-state nil
  "The state of a torus."
  :tag "MTorus State"
  :prefix "mtorus-state-"
  :group 'mtorus)


(defconst mtorus-state-version "Version: 0.1 $Revision$"
  "Version of mtorus-state backend.
THIS IS NOT WORKING AT THE MOMENT!")



(define-mtorus-type dump
  :predicate
  (lambda (element)
    (eq (mtorus-element-get-property 'type element) 'dump))
  :inherit-selection
  (lambda (element)
    (error "MTorus type dump is not selectable"))
  :alive-p
  (lambda (element)
    t)
  )
  

(eval
 `(define-mtorus-convert dump
   ,@(let (spec)
       (mapc #'(lambda (keyw)
                 (setq spec
                       (append
                        spec
                        (list keyw
                              `(plist-get prop::value ',keyw)))))
             (mtorus-type-convert-list))
       spec)
   :type 'dump
   :value
   ,(cons 'list
          (let (spec)
            (mapc #'(lambda (keyw)
                      (setq spec
                            (append
                             spec
                             `(',keyw
                               ,(mtorus-utils-namespace-conc 'conv keyw)))))
                  (mtorus-type-convert-list))
            spec))))


;;(mtorus-type-convert-to 'dump (gethash mtorus-current-element mtorus-elements))


(defun mtorus-state-object-dumpable-p (object)
  "Returns object if it is dumpable, nil otherwise."
  (string= (format "%s" object)
           (format "%S" object)))

(defun mtorus-state-save ()
  "Saves current mtorus to a dump buffer."
  ;; first we dump all elements
  (let ((tempbuf (get-buffer-create "*MTorus Dump*"))
;;        (dump-ht (make-hash-table :test 'equal))
        )
    (erase-buffer tempbuf)
    (with-current-buffer tempbuf
      (maphash
       #'(lambda (elem el-prop-ht)
           (insert
            (format
             "%S\n"
             (eval 
              `(vector
                :type '',(mtorus-element-get-type elem)
                :symbol '',elem
                ,@(mtorus-element-property-get
                   'value
                   (mtorus-type-convert-to 'dump el-prop-ht))))
             )))
       (eval mtorus-elements-hash-table))
      (mapc #'(lambda (nh)
                (maphash #'(lambda (key val)
                             (maphash #'(lambda (el rel)
                                          (insert (format "%s: %s - %s\n" rel key el)))
                                      val))
                         (eval (mtorus-utils-symbol-conc
                                'mtorus-topology-standard nh))))
            mtorus-topology-standard-neighborhoods))
    tempbuf)

  ;; now the topology
  )

;;(mtorus-state-save)


;;(format "%S" (current-buffer))



(defun mtorus-state-load ()
  ""

(with-current-buffer (get-buffer-create "*MTorus Dump*")
  (goto-char (point-min)) (insert "(\n")
  (goto-char (point-max)) (insert "\n)")
  (goto-char (point-min))
  (setq records (read (current-buffer))))
  )



(provide 'mtorus-state)

;;; mtorus-state.el ends here
