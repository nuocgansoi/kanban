class JournalController < ApplicationController
  
  def index
  end
  
  #
  # Nhận tạp chí
  #
  def get_journal
    # POST Nhận giá trị
    card_id = params[:card_id]
    
    # Nhận ID thẻ
    issue_array = card_id.split("-")
    issue_id = issue_array[1].to_i

    # Giá trị trả về
    result_hash = {}

    # Nhận thẻ
    issue = Issue.find(issue_id);

    # Hiển thị tiêu đề
    notes_string ="<p><b>#" + issue_id.to_s + "</b></p>"
    notes_string ="<a href=\"../issues/" + issue_id.to_s + "\"><p><b>#" + issue_id.to_s + "</b><p></a>"

    # Cột mô tả
    if !issue.description.blank? then
      user = User.find(issue.author_id)
      notes_string += "<table class=\"my-journal-table\">"
      notes_string += "<tr>"
      notes_string += "<th>"
      notes_string += "<a href=\"../issues/" + issue_id.to_s + "\">"
      notes_string += issue.created_on.strftime("%Y-%m-%d %H:%M:%S")
      notes_string += "</a>"
      notes_string += "　"
      notes_string += user.lastname
      notes_string += ""
      notes_string += "</th>"
      notes_string += "</tr>"
      notes_string += "<tr>"
      notes_string += "<td>"
      notes_string += CGI.escapeHTML(trim_notes(issue.description))
      notes_string += "</td>"
      notes_string += "</tr>"
      notes_string += "</table>"
    end

    # Nhận ghi chú (3 mới nhất)
    notes = Journal.where(journalized_id: issue_id)
                   .where(journalized_type: "Issue")
                   .where(private_notes: 0)
                   .where("notes IS NOT NULL")
                   .where("notes <> ''")
                   .limit(3)
                   .order("created_on DESC")

    # Hiển thị tiêu đề
    if !notes.blank? then
      notes_string +="<p><b>Lịch sử mới nhất</b></p>"
    end

    # Tạo ghi chú với BẢNG
    notes.reverse_each {|note|
      if !note.notes.blank? then
        user = User.find(note.user_id)
        notes_string += "<table class=\"my-journal-table\">"
        notes_string += "<tr>"
        notes_string += "<th>"
        notes_string += "<a href=\"../issues/" + issue_id.to_s + "#change-" + note.id.to_s + "\">"
        notes_string += note.created_on.strftime("%Y-%m-%d %H:%M:%S")
        notes_string += "</a>"
        notes_string += "　"
        notes_string += user.lastname
        notes_string += ""
        notes_string += "</th>"
        notes_string += "</tr>"
        notes_string += "<tr>"
        notes_string += "<td>"
        notes_string += CGI.escapeHTML(trim_notes(note.notes))
        notes_string += "</td>"
        notes_string += "</tr>"
        notes_string += "</table>"
      end
    }

    # Mẫu bình luận
    notes_string += "<p><b>Gửi ý kiến</b></p>"
    notes_string += "<table class=\"my-comment-table\"><tr><td>"
    notes_string += "<textarea id=\"comment_area\" class=\"my-comment-textarea\" rows=\"5\"></textarea>"
    notes_string += "<p><input type=\"button\" id=\"submit-journal-button\" value=\"Gửi\"></p>"
    notes_string += "</td></tr></table>"
    
    # Trở về
    result_hash["result"] = "OK"
    result_hash["notes"] = notes_string
    render json: result_hash
  end

  #
  # Bỏ qua ghi chú
  #
  def trim_notes(notes)
    str = notes.byteslice(0, Constants::MAX_NOTES_BYTESIZE).scrub('')
    if notes.bytesize >= Constants::MAX_NOTES_BYTESIZE then
      str += "..."
    end
    return str
  end

  #
  # Thêm tạp chí
  #
  def put_journal
    # POST Nhận giá trị
    card_id = params[:card_id]
    note = params[:note]
    
    # Giá trị trả về
    result_hash = {}

    # Nhận ID thẻ
    issue_array = card_id.split("-")
    issue_id = issue_array[1].to_i

    # Nhận thẻ
    issue = Issue.find(issue_id)

    # Thêm ghi chú
    note = Journal.new(:journalized => issue, :notes => note, user: User.current)
    note.save!

    # Trở về
    result_hash["result"] = "OK"
    render json: result_hash
  end

end
