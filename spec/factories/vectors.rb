FactoryGirl.define do
    factory :vector do
        original_inputs({
            'pname1' => 'pvalue1',
            'pname2' => 'pvalue2'
        })
        inputs({
            'pname1' => '/etc/passwd',
            'pname2' => 'pvalue2'
        })
        seed "/etc/passwd"
        arachni_class "Arachni::Element::Form"
        type "form"
        action "http://test.com/"
        html "<form>stuff</form>"
        http_method "POST"
        affected_input_name "pname1"
    end
end
