(asdf:defsystem my-project
  :components ((:file "package")
               (:file "main"))
  :depends-on (:trial
               :trial-glfw
               :trial-png))
