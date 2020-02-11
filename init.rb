Redmine::Plugin.register :kanban do
  name 'Kanban plugin'
  author 'Kohei Nomura'
  description 'Kanban plugin for redmine'
  version '0.0.5'
  url 'https://github.com/happy-se-life/kanban'
  author_url 'mailto:kohei_nom@yahoo.co.jp'

  #Hiển thị "Kanban" trong menu ứng dụng
  menu :application_menu, :kanban, { :controller => 'kanban', :action => 'index' }, :caption => 'Kanban', :if => Proc.new { User.current.logged? }

  #Hiển thị "Kanban" trong menu dự án
  menu :project_menu, :kanban, { :controller => 'kanban', :action => 'index' }, :caption => 'Kanban', :param => :project_id

  # Thêm quyền cho từng dự án
  project_module :kanban do
    permission :kanban, {:kanban => [:index]}
 end
end
